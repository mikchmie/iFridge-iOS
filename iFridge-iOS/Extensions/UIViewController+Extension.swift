//
//  UIViewController+Extension.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

extension UIViewController {

    func displayDefaultAlertView(title: String, message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })

        alertController.addAction(action)

        self.present(alertController, animated: true)
    }
}
