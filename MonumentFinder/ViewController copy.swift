////
////  ViewController.swift
////  MonumentFinder
////
////  Created by Jacopo Gasparetto on 02/10/2017.
////  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
////
//// swiftlint:disable type_body_length
//// swiftlint:disable file_length
//
//import ARKit
//import MapKit
//import SceneKit
//import UIKit
//
//@available(iOS 11.0, *)
//class ViewController: UIViewController, AugmentedRealityDataSource,
//    UIGestureRecognizerDelegate, SettingsViewControllerDelegate {
//    
//    let maxVisibleMonuments = 20
//
//    /// Whether to display some debugging data
//    /// This currently displays the coordinate of the best location estimate
//    /// The initial value is respected
//    var displayDebug = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool ?? false
//    var infoLabel = UILabel()
//
//    var updateInfoLabelTimer: Timer?
//    lazy var maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as? Double ?? 500
//    var comingFromBackground = false
//    var isFirstRun = true
//    var scaleRelativeToDistance = UserDefaults.standard.bool(forKey: "scaleRelativeTodistance")
//
//    // lazy var oldUserLocation = UserDefaults.standard.object(forKey: "oldUserLocation") as? CLLocation
//    var monuments = [Monumento]()
//    var visibleMonuments = [Monumento]()
//    var numberOfVisibibleMonuments = 0
//    var countLabel = UILabel()
//    var effect: UIVisualEffect!
//
//    let sceneLocationView = SceneLocationView()
//
//    // Set IBOutlet
//    @IBOutlet var noPOIsView: UIView!
//    @IBOutlet var blurVisualEffectView: UIVisualEffectView!
//    @IBOutlet var locationAlertView: UIView!
//
//    @IBAction func setMaxVisiblità(_ sender: Any) {
//        setMaxDistance()
//    }
//
//    // ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("viewDidLoad\n")
//
//        // Setup blur visual effect
//        effect = blurVisualEffectView.effect
//        blurVisualEffectView.effect = nil
//        noPOIsView.layer.cornerRadius = 5
//        blurVisualEffectView.isUserInteractionEnabled = false
//
//        // Setup SceneLocationView
//        // Set to true to display an arrow which points north.
//        // Checkout the comments in the property description and on the readme on this.
//        sceneLocationView.orientToTrueNorth = false
//
//        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
//        sceneLocationView.locationDelegate = self
//
//        view.addSubview(sceneLocationView)
//        view.sendSubview(toBack: sceneLocationView) // send sceneLocationView behind the IB elements
//        // sceneLocationView.isJitteringEnabled = true              // Is it useful?
//        sceneLocationView.antialiasingMode = .multisampling4X
//
//        setupCountLabel() // Create the UILabel that counts the visible annotations
//
//        // Notification observers
//        let nc = NotificationCenter.default
//        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
//                       name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
//        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
//                       name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
//        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
//                       name: Notification.Name("pauseSceneLocationView"), object: nil)
//        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
//                       name: Notification.Name("resumeSceneLocationView"), object: nil)
//        nc.addObserver(self, selector: #selector(updateLocationNodes),
//                       name: Notification.Name("reloadAnnotations"), object: nil)
//        nc.addObserver(self, selector: #selector(orientationDidChange),
//                       name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
//
//        let tapRecognizer = UITapGestureRecognizer()
//        tapRecognizer.numberOfTapsRequired = 1
//        tapRecognizer.numberOfTouchesRequired = 1
//        tapRecognizer.addTarget(self, action: #selector(sceneTapped))
//        sceneLocationView.gestureRecognizers = [tapRecognizer]
//
//        shouldDisplayDebugAtStart()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("\nViewWillAppear")
//        print("Run sceneLocationView\n")
//        sceneLocationView.run()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        print("viewDidDisappear")
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("View will disappear")
//        print("Pause sceneLocationView\n")
//        removeLocationNodes() // Remove old locationNodes
//        sceneLocationView.pause()
//    }
//
//    override func viewDidLayoutSubviews() {
//        sceneLocationView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: view.frame.size.width,
//            height: view.frame.size.height)
//
//        infoLabel.frame = CGRect(
//            x: 6,
//            y: 0,
//            width: 300,
//            height: 14 * 4)
//        infoLabel.center = CGPoint(x: view.center.x, y: view.frame.height - infoLabel.frame.height / 2)
//    }
//
//    @objc func resumeSceneLocationView() {
//        sceneLocationView.run()
//        //        comingFromBackground = true ???
//        print("Resume sceneLoationView\n")
//    }
//
//    @objc func pauseSceneLocationView() {
//        sceneLocationView.pause()
//        if let currentLocation = sceneLocationView.currentLocation() {
//            let archivedUserLocation = NSKeyedArchiver.archivedData(withRootObject: currentLocation)
//            UserDefaults.standard.set(archivedUserLocation, forKey: "oldUserLocation")
//            print("oldUserLocation successfully saved.")
//        } else {
//            print("Failed to save oldUserLocation")
//        }
//        print("Pause sceneLoationView\n")
//    }
//
//    @objc func orientationDidChange() {
//        let orientation = UIDevice.current.orientation
//
//        // print("orientationDidChange: \(orientation)")
//        var angle: CGFloat = 0.0
//        switch orientation {
//        case .landscapeLeft:
//            angle = .pi / 2
//        case .landscapeRight:
//            angle = -.pi / 2
//        default:
//            angle = 0.0
//        }
//        let rotation = CGAffineTransform(rotationAngle: angle)
//        UIView.animate(withDuration: 0.2) {
//            for view in self.view.subviews where view is UIButton {
//                view.transform = rotation
//            }
//        }
//    }
//
//    // MARK: Add annotationView
//
//    func shouldUpdateLocationNodesForCurrentLocation(location: CLLocation) -> Bool {
//        if let archivedData = UserDefaults.standard.data(forKey: "oldUserLocation") {
//            if let oldUserLocation = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? CLLocation {
//                if location.distance(from: oldUserLocation) > 1000 {
//                    return true
//                } else {
//                    print("No need to reset locationNodes.\n")
//                    return false
//                }
//            } else {
//                print("Failed to read oldUserLocation")
//                return false
//            }
//        } else {
//            print("No oldUserLocation found, reload locationNodes")
//            return true
//        }
//    }
//
//    // Fill the dataSource binding the Annotation with the AnnotationView.
//    func augmentedReality(_ viewController: UIViewController, viewForAnnotation: Monumento) -> AnnotationView {
//        let annotationView = AnnotationView(annotation: viewForAnnotation)
//        annotationView.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
//        annotationView.layer.cornerRadius = annotationView.frame.size.height / 2.0
//        annotationView.clipsToBounds = true
//        annotationView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
//        // annotationView.backgroundColor = UIColor.white
//
//        return annotationView
//    }
//
//    /// Create return a LocationAnnotationNode object given a Monumento object
//    func setupLocationNode(monument: Monumento) -> MNLocationAnnotationNode {
//        if let currentLocation = sceneLocationView.locationManager.currentLocation {
//            monument.altitude = 0
//            let distanceFromUser = currentLocation.distance(from: monument.location)
//            monument.distanceFromUser = distanceFromUser
//        }
//        //        monument.altitude = (monument.distanceFromUser - 59) * 0.3
//        let annotationView = augmentedReality(self, viewForAnnotation: monument)
//
//        let annotationImage = generateImageFromView(inputView: annotationView)
//        let annotationNode = MNLocationAnnotationNode(annotation: monument, image: annotationImage)
//
//        return annotationNode
//    }
//
//    /// Add locationNodes closer than maxDistance. Extract annotations from the quadTree object and create a UIImage
//    /// for each annotation to be used in SceneLocationView.
//    func addLocationNodesForUserLocation(userLocation: CLLocation) {
//        print("Adding annotations for current location: \(userLocation.coordinate.description!)...")
//
//        // Extract monuments within a MKMapRect centered on the user location.
//        let span = MKCoordinateSpanMake(0.1, 0.1)
//        let coordinateRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
//        let rect = coordinateRegion.toMKMapRect()
//        monuments = quadTree.annotations(in: rect) as! [Monumento]
//
//        // Add the annotation
//        for monument in monuments {
//            monument.distanceFromUser = monument.location.distance(from: userLocation)
//        }
//
////        let sortedMonuments = monuments.sorted(by: { $0.distanceFromUser < $1.distanceFromUser })[0..<maxVisibleMonuments]
//        let sortedMonuments = monuments.sorted(by: { $0.distanceFromUser < $1.distanceFromUser })
//
//        for monument in sortedMonuments {
//            let annotationNode = setupLocationNode(monument: monument)
//            annotationNode.scaleRelativeToDistance = scaleRelativeToDistance
//            annotationNode.name = monument.title
//            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
//        }
//
//        updateLocationNodes() // Check the visibility
//        print("\(sceneLocationView.locationNodes.count) nodes created.")
//    }
//
//    /// Remove all existing locationNodes
//    func removeLocationNodes() {
//        if !sceneLocationView.locationNodes.isEmpty {
//            let nodes = sceneLocationView.locationNodes
//            for node in nodes {
//                sceneLocationView.removeLocationNode(locationNode: node)
//            }
//        }
//        print("locationNodes removed\n")
//    }
//
//    /// Update the locationNodes revealing or hiding based on distanceFromUser
//    @objc func updateLocationNodes() {
//        print("Update location nodes")
//        visibleMonuments = monuments.filter({(monumento: Monumento) -> Bool in monumento.isActive})
//
//        let locationNodes = sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
//
//        if let currentLocation = sceneLocationView.currentLocation() {
//            // Count the number visible monuments and animate the label counter
//            var count = 0
//            for monument in monuments {
//                if currentLocation.distance(from: monument.location) <= maxDistance {
//                    count += 1
//                }
//            }
//            labelCounterAnimate(count: count)
//
//            // Check if the locationNode is visibile. Use a delay to animate one node per time
//            var index = 0
//            locationNodes.forEach { locationNode in
//                index += 1
//                self.delay(Double(index) * 0.05) {
//                    let isActive = self.checkIfAnnotationIsActive(annotationNode: locationNode)
//                    let distanceFromUser = currentLocation.distance(from: locationNode.location)
//                    // Hide far locationNode
//                    if distanceFromUser <= self.maxDistance {
//                        if locationNode.isHidden && isActive {
//                            self.revealLocationNode(locationNode: locationNode, animated: true)
//                        } else if !locationNode.isHidden && !isActive {
//                            self.hideLocationNode(locationNode: locationNode, animated: true)
//                        }
//                    } else {
//                        if !locationNode.isHidden {
//                            self.hideLocationNode(locationNode: locationNode, animated: true)
//                        }
//                    }
//                }
//            }
//        } else {
//            print("Failed to updateLocationNodes(): no location.\n")
//        }
//    }
//
//    /// Set the locationNode isHidden = false and run the animation to reveal it.
//    func revealLocationNode(locationNode: LocationNode, animated: Bool) {
//        locationNode.isHidden = false
//        locationNode.opacity = 0.0
//        //        locationNode.childNodes.first?.position.y += 10
//
//        if animated {
//            // let scaleOut = SCNAction.scale(by: 3, duration: 0.5)
//            let fadeIn = SCNAction.fadeIn(duration: 0.2)
//            //            let moveIn = SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 0.2)
//            let moveFromTop = SCNAction.group([fadeIn /* , moveIn */ ])
//            locationNode.childNodes.first?.runAction(moveFromTop)
//            locationNode.runAction(fadeIn)
//        }
//    }
//
//    /// Set the locationNode isHidden = true and run the animation to hide it.
//    func hideLocationNode(locationNode: LocationNode, animated: Bool) {
//        if animated {
//            // let scaleOut = SCNAction.scale(by: 3, duration: 0.5)
//            //            let oldY = locationNode.childNodes.first?.position.y
//            let fadeOut = SCNAction.fadeOut(duration: 0.2)
//            //            let moveOut = SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 0.2)
//            let moveToDown = SCNAction.group([fadeOut /* , moveOut */ ])
//            locationNode.childNodes.first?.runAction(
//                moveToDown, completionHandler: {
//                    locationNode.isHidden = true
//                    //                locationNode.childNodes.first?.position.y = oldY!
//            })
//        }
//    }
//
//    /// Convert a UIView to a UIImage
//    func generateImageFromView(inputView: UIView) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
//        inputView.drawHierarchy(in: inputView.bounds, afterScreenUpdates: true)
//        let uiImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return uiImage
//    }
//
//    /// Delay the exectution of the inner block (in seconds).
//    func delay(_ delay: Double, closure: @escaping () -> Void) {
//        DispatchQueue.main.asyncAfter(
//            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
//    }
//
//    // MARK: active monuments
//    /// Iterate for each annotation and check if it should be visible according to the active filters
//    func checkIfAnnotationIsActive(annotationNode: MNLocationAnnotationNode) -> Bool {
//        var isActive = false
//        let activeFilters = filtri.filter {
//            $0.selected
//        }.map {
//            $0.osmtag
//        }
//        let osmtag = annotationNode.annotation.osmtag
//        for filter in activeFilters where osmtag == filter {
//            isActive = true
//        }
//        return isActive
//    }
//
//    // MARK: Update counterLabel
//    func setupCountLabel() {
//        countLabel.frame = CGRect(x: 0, y: 0, width: 210, height: 20)
//        countLabel.center = CGPoint(x: view.bounds.size.width / 2, y: -countLabel.frame.height)
//        countLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
//        countLabel.layer.cornerRadius = countLabel.frame.height / 2.0
//        countLabel.clipsToBounds = true
//        countLabel.layer.borderColor = UIColor.black.cgColor
//        countLabel.layer.borderWidth = 0.5
//        countLabel.font = UIFont(name: defaultFontName, size: 12)
//        countLabel.textAlignment = .center
//    }
//
//    /// Drop down the label counter for visible objects. count: number of item to count
//    func labelCounterAnimate(count: Int) {
//        if count > 0 {
//            countLabel.text = "\(count) oggetti visibili"
//            if view.subviews.contains(noPOIsView) {
//                noPOIsViewAnimateOut()
//            }
//        } else {
//            countLabel.text = "Nessun oggetto visibile"
//            if !view.subviews.contains(noPOIsView) {
//                noPOIsViewAnimateIn()
//            }
//        }
//
//        let oldCenter = CGPoint(x: view.bounds.width / 2, y: -countLabel.bounds.height)
//
//        if !view.subviews.contains(countLabel) {
//            countLabel.center = oldCenter
//
//            view.addSubview(countLabel)
//            UIView.animate(
//                withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//                    self.countLabel.center = CGPoint(x: self.view.bounds.width / 2, y: 50)
//                }, completion: { _ in
//                    UIView.animate(
//                        withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
//                            self.countLabel.center = oldCenter
//                        }, completion: { _ in
//                            self.countLabel.removeFromSuperview()
//                    })
//            })
//        }
//    }
//
//    func noPOIsViewAnimateIn() {
//        view.addSubview(noPOIsView)
//        noPOIsView.center = view.center
//        noPOIsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        noPOIsView.alpha = 0
//
//        UIView.animate(withDuration: 0.4) {
//            self.blurVisualEffectView.effect = self.effect
//            self.noPOIsView.alpha = 1
//            self.noPOIsView.transform = .identity
//        }
//    }
//
//    func noPOIsViewAnimateOut() {
//        UIView.animate(
//            withDuration: 0.3, animations: {
//                self.noPOIsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                self.noPOIsView.alpha = 0
//
//                self.blurVisualEffectView.effect = nil
//            }, completion: { (_: Bool) in
//                self.noPOIsView.removeFromSuperview()
//        })
//    }
//
//    // MARK: Handle tap gestures
//    @objc func sceneTapped(recognizer: UITapGestureRecognizer) {
//        let location = recognizer.location(in: sceneLocationView)
//        print("Tap at location: \(location)\n")
//
//        let options = [
//            SCNHitTestOption.backFaceCulling: false,
//            SCNHitTestOption.firstFoundOnly: false,
//            SCNHitTestOption.ignoreChildNodes: false,
//            SCNHitTestOption.clipToZRange: false,
//            SCNHitTestOption.ignoreHiddenNodes: false
//        ]
//        let hitResults = sceneLocationView.hitTest(location, options: options)
//        print(hitResults)
//        for hit in hitResults {
//            if let hitnode = hit.node.parent as? MNLocationAnnotationNode {
//                print("\(hitnode.annotation.title!) \(hitnode.position)")
//                let annotationDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
//                    withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
//
//                annotationDetailsVC.titolo = hitnode.annotation.title
//                annotationDetailsVC.categoria = hitnode.annotation.categoria
//                annotationDetailsVC.wikiUrl = hitnode.annotation.wikiUrl
//
//                annotationDetailsVC.modalPresentationStyle = .overCurrentContext
//
//                present(annotationDetailsVC, animated: true, completion: nil)
//
//            } else {
//                print("result is not MNLocationAnnotationNode")
//            }
//        }
//    }
//
//    // MARK: Update debugging infoLabel
//    @objc func updateInfoLabel() {
//        if let position = sceneLocationView.currentScenePosition() {
//            infoLabel.text = "x: \(String(format: "%.2f", position.x)), " +
//            "y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
//        }
//
//        if let eulerAngles = sceneLocationView.currentEulerAngles() {
//            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), " +
//                "y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
//        }
//
//        if let heading = sceneLocationView.locationManager.heading,
//            let accuracy = sceneLocationView.locationManager.headingAccuracy {
//            infoLabel.text!.append("Heading: \(String(format: "%.2f", heading))º, accuracy: \(Int(round(accuracy)))º\n")
//        }
//
//        let date = Date()
//        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
//
//        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
//            infoLabel.text!.append(
//                "\(String(format: "%02d", hour)):" +
//                "\(String(format: "%02d", minute)):\(String(format: "%02d", second)):" +
//                "\(String(format: "%03d", nanosecond / 1000000))"
//            )
//        }
//    }
//
//    // MARK: SceneLocationViewDelegate
//
//    // MARK: MaxDistance button
//    // Configura il bottone trasparente per chidere la bubble
//    func setMaxDistance() {
//        let bottoneTrasparente = UIButton()
//        bottoneTrasparente.frame = view.frame
//        view.addSubview(bottoneTrasparente)
//        bottoneTrasparente.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
//
//        // Disegna la bubble view sopra qualsiasi cosa
//        let width = view.frame.size.width - 50
//        let yPos = view.frame.size.height - 80
//        let bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: width, height: 100))
//        bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
//        bubbleView.center = CGPoint(x: view.frame.midX, y: yPos)
//        bubbleView.tag = 99
//        let currentWindow = UIApplication.shared.keyWindow
//        currentWindow?.addSubview(bubbleView)
//        bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0)
//        UIView.animate(
//            withDuration: 0.1,
//            delay: 0.0,
//            usingSpringWithDamping: 0.8,
//            initialSpringVelocity: 0,
//            options: .curveEaseInOut,
//            animations: {
//                bubbleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }, completion: nil)
//    }
//
//    @objc func dismiss(sender: UIButton) {
//        let currentWindow = UIApplication.shared.keyWindow
//        if let bubbleView = currentWindow?.viewWithTag(99) {
//            UIView.animate(
//                withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
//                    bubbleView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                    bubbleView.alpha = 0
//                }, completion: { _ in
//                    sender.removeFromSuperview()
//                    bubbleView.removeFromSuperview()
//            })
//        }
//        // Update maxDistance and reload annotations
//        maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
//        print("Visibilità impostata a \(maxDistance.rounded()) metri.\n")
//        updateLocationNodes()
//    }
//
//    // MARK: Prepare for segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare")
//        if segue.identifier == "toSettingsVC" {
//            let navigationController = segue.destination as! UINavigationController
//            let settingsVC = navigationController.topViewController as! SettingsVC
//            settingsVC.delegate = self
//        }
//    }
//
//    // MARK: Debug mode
//    func shouldDisplayDebugAtStart() {
//        let shouldDisplayARDebug = UserDefaults.standard.bool(forKey: "switchArFeaturesState")
//        let shouldDisplaDebugFeatures = UserDefaults.standard.bool(forKey: "switchDebugState")
//
//        if shouldDisplayARDebug {
//            displayARDebug(isVisible: true)
//        }
//        if shouldDisplaDebugFeatures {
//            displayDebugFeatures(isVisible: true)
//        }
//    }
//
//    func scaleLocationNodesRelativeToDistance(_ shouldScale: Bool) {
//        print("scale Locationnodes relative to distance.\n")
//        guard let userLocation = sceneLocationView.currentLocation() else {
//            print("scaleLocationNodesRelativeToDistance: Failed to retrieve user location. Nothing will change")
//            return
//        }
//
//        removeLocationNodes()
//        scaleRelativeToDistance = shouldScale
//        addLocationNodesForUserLocation(userLocation: userLocation)
//    }
//
//    func displayARDebug(isVisible: Bool) {
//        if isVisible {
//            print("display AR Debug\r")
//            sceneLocationView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//
//            infoLabel.font = UIFont.systemFont(ofSize: 10)
//            infoLabel.textAlignment = .left
//            infoLabel.textColor = UIColor.white
//            infoLabel.numberOfLines = 0
//            sceneLocationView.addSubview(infoLabel)
//
//            updateInfoLabelTimer = Timer.scheduledTimer(
//                timeInterval: 0.1,
//                target: self,
//                selector: #selector(updateInfoLabel),
//                userInfo: nil,
//                repeats: true)
//        } else {
//            print("hide AR Debug\r")
//            sceneLocationView.debugOptions = []
//            infoLabel.removeFromSuperview()
//            updateInfoLabelTimer?.invalidate()
//        }
//    }
//
//    func displayDebugFeatures(isVisible: Bool) {
//        if isVisible {
//            print("display Debug Features\r")
//            sceneLocationView.showsStatistics = true
//        } else {
//            print("display Debug Features")
//            sceneLocationView.showsStatistics = false
//        }
//    }
//}
//
//// MARK: SceneLocationViewDelegate
//@available(iOS 11.0, *)
//extension ViewController: SceneLocationViewDelegate {
//    
//    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView,
//                                                      position: SCNVector3,
//                                                      location: CLLocation) {
//        // Create the annotations only when a location estimate is available
////        if isFirstRun {
////            addLocationNodesForUserLocation(userLocation: location)
////            isFirstRun = false
////        } else if comingFromBackground {
////            if shouldUpdateLocationNodesForCurrentLocation(location: location) {
////                removeLocationNodes()
////                addLocationNodesForUserLocation(userLocation: location)
////            }
////            comingFromBackground = false
////        }
//    }
//
//    
//    func sceneLocationViewDidRemoveSceneLocationEstimate(
//        sceneLocationView: SceneLocationView, position: SCNVector3,
//        location: CLLocation) {
//        // print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy:
//        // \(location.horizontalAccuracy), date: \(location.timestamp)")
//    }
//    
//    func sceneLocationViewDidAddLocationNode(sceneLocation View: SceneLocationView, locationNode: LocationNode) {
//        
//    }
//    
//    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
//        
//    }
//    
//    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
//        print("SceneNode setup completed.")
//    }
//    
//    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView,
//                                                                  locationNode: LocationNode) {
//    }
//}
