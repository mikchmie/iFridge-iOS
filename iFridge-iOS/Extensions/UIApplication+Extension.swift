//
//  UIApplication+Extension.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

extension UIApplication {

    class var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
