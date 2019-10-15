//
//  AppDelegate.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 08/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver
import CoreLocation.CLLocationManager
import AVFoundation.AVCaptureDevice

let logger = SwiftyBeaver.self

let preloadDataKey = "didPreloadData"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authorizationsNeeded: [AuthorizationRequestType]?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let console = ConsoleDestination()
        console.levelColor.debug = "🐞 "
        console.levelColor.error = "❌ "
        console.levelColor.info = "ℹ️ "
        console.levelColor.verbose = "📣 "
        console.levelColor.warning = "⚠️ "
        logger.addDestination(console)
        
        logger.info("Running application...\n\n")
        
        preloadData()
        
        let config = EnvironmentConfiguration()
        let dataCollection = DataCollection()
        dataCollection.readFromDatabase()
        readMonumentTagsFromCsv()
        loadCategoriesState()
        
        Theme.apply()
        if let maxDistance = UserDefaults.standard.object(forKey: "maxVisibility") as? Int {
            global.maxDistance = maxDistance
        } else {
            global.maxDistance = config.maxDistance
        }
        
        // Wait for Launch Screen
        Thread.sleep(forTimeInterval: 1.0)
        
        // Decide initial controller
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController
        
        if let authorizationsNeeded = authorizationRequestsNeeded() {
            let onboardingViewController = storyBoard.instantiateViewController(identifier: "OnboardingViewController") as! OnboardingViewController
            onboardingViewController.authorizationsNeeded = authorizationsNeeded
            viewController = onboardingViewController
            viewController.endAppearanceTransition()
            
        } else {
            viewController = storyBoard.instantiateViewController(identifier: "ViewController")
        }
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types
		// of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits
		// the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
		// Games should use this method to pause the game.

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
		// and store enough application state information to restore your application to its current state in case
		// it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate:
		// when the user quits.
//        if #available(iOS 11.0, *) {
//            if let vc = self.window?.rootViewController as? ViewController {
//                vc.pauseSceneLocationView()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the
		// changes made on entering the background.
//        print("appWillEnterForeground")
//        let nc = NotificationCenter.default
//        nc.post(Notification.init(name: Notification.Name(rawValue: "appWillEnterForeground")))
//        if #available(iOS 11.0, *) {
//            if let vc = self.window?.rootViewController as? ViewController {
//                vc.resumeSceneLocationView()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "mapViewRegion")

    }
    // MARK: Custom functions
 
    func readMonumentTagsFromCsv() {
        // Legge il CSV
        let fileURL = Bundle.main.url(forResource: "MonumentTags", withExtension: "csv")
        do {
            let csvString = try NSString.init(contentsOf: fileURL!, encoding: String.Encoding.utf8.rawValue)
            let rows = csvString.components(separatedBy: "\n")
            for row in rows {
                let monumentTagsComponents = row.components(separatedBy: ";")
                if monumentTagsComponents.count > 1 { // TODO: improve this
                    let osmtag = monumentTagsComponents[0]
                    let priority = monumentTagsComponents[1]
                    let description = monumentTagsComponents[2]
                    let category = monumentTagsComponents[3]
                    global.categories.append(Category(osmtag: osmtag,
                                             description: description,
                                             category: category,
                                             priority: Int(priority)!))
                }
            }
        } catch {
            
        }
    }
    
    // If there aren't categories which state was set by user, set the selected state true for all
    func loadCategoriesState() {
        if let selectedOsmTags = UserDefaults.standard.stringArray(forKey: "selectedOsmTags")  {
            global.categories.forEach { $0.selected = (selectedOsmTags.contains($0.osmtag))}
        } else {
            global.categories.forEach {$0.selected = true }
        }
    }
    
    // MARK: - Preload Data
     
     private func loadPlistFile<T>(forResource resource: String, forType type: T.Type) -> T where T: Decodable {
         guard let plistUrl = Bundle.main.url(forResource: resource, withExtension: "plist") else {
             fatalError("Cannot locate file \(resource).plist")
         }
         do {
             let plistData = try Data(contentsOf: plistUrl)
             let decoder = PropertyListDecoder()
             let decodedData = try decoder.decode(type.self, from: plistData)
             return decodedData
         } catch {
             fatalError("Cannot decode data, error: \(error)")
         }
     }
     
     private func preloadData() {
         let userDefaults = UserDefaults.standard
         
         if userDefaults.bool(forKey: preloadDataKey) == false {
             
             let backgroundContext = persistentContainer.newBackgroundContext()
             persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
             
             backgroundContext.perform {
                 do {
                    logger.info("Preloading data")
                     let monumentData = self.loadPlistFile(forResource: "Monuments", forType: MonumentData.self)
                     let monuments = monumentData.monuments
                     
                     for monument in monuments {
                        let monumentObject = Monument(context: backgroundContext)
                        monumentObject.name = monument.name
                        monumentObject.category = monument.category
                        monumentObject.latitude = monument.latitude
                        monumentObject.longitude = monument.longitude
                        monumentObject.wikiUrl = monument.tags["wikiUrl"]
                    }
                     
                     try backgroundContext.save()
                     userDefaults.set(true, forKey: preloadDataKey)
                 } catch {
                     print(error.localizedDescription)
                 }
             }
         }
    }
    
     // MARK: - Core Data stack

     lazy var persistentContainer: NSPersistentContainer = {
         /*
          The persistent container for the application. This implementation
          creates and returns a container, having loaded the store for the
          application to it. This property is optional since there are legitimate
          error conditions that could cause the creation of the store to fail.
         */
         let container = NSPersistentContainer(name: "Monuments")
         container.loadPersistentStores(completionHandler: { (storeDescription, error) in
             if let error = error as NSError? {
                 // Replace this implementation with code to handle the error appropriately.
                 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  
                 /*
                  Typical reasons for an error here include:
                  * The parent directory does not exist, cannot be created, or disallows writing.
                  * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                  * The device is out of space.
                  * The store could not be migrated to the current model version.
                  Check the error message to determine what the actual problem was.
                  */
                 fatalError("Unresolved error \(error), \(error.userInfo)")
             }
         })
         return container
     }()

     // MARK: - Core Data Saving support

     func saveContext () {
         let context = persistentContainer.viewContext
         if context.hasChanges {
             do {
                 try context.save()
             } catch {
                 // Replace this implementation with code to handle the error appropriately.
                 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 let nserror = error as NSError
                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
             }
         }
     }
}


// MARK: - Authorizations

enum AuthorizationRequestType {
    case location, camera
}
 
extension AppDelegate {
    
    private func authorizationRequestsNeeded() -> [AuthorizationRequestType]? {
        var requests: [AuthorizationRequestType]?
        
        let locationStatus = CLLocationManager.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        let locationNeeded = locationStatus == .notDetermined || locationStatus == .restricted || locationStatus == .denied
        let cameraNeeded = cameraStatus == .notDetermined || cameraStatus == .restricted || cameraStatus == .denied
        
        if locationNeeded { requests?.append(.location) ?? (requests = [.location]) }
        if cameraNeeded { requests?.append(.camera) ?? (requests = [.camera])}
        return requests
    }
}

