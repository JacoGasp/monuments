//
//  Constants.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 29/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct Constants {
    
    struct Colors {
        static let primary = Color(#colorLiteral(red: 0.7994838357, green: 0.2183310688, blue: 0.165236026, alpha: 1))
        static let secondary = Color(#colorLiteral(red: 0.9537991881, green: 0.2298480868, blue: 0.2896286845, alpha: 1))
    }
    
    struct Fonts {
        static let body = Font.body.weight(.light)
        static let subtitle = Font.system(size: 12).weight(.light)
        static let trajanTitle = Font.custom("Trajan Pro", size: 38)
    }   
}
