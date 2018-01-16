//
//  UIViewController+Present.swift
//  BalanceiOS
//
//  Created by Eli Pacheco Hoyos on 1/10/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showSimpleMessage(title: String, message: String) {
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
    }
    
}
