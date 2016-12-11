//
//  Date+Extensions.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 11.12.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

extension Date {

    var timestamp: Int {

        return Int(self.timeIntervalSince1970 * 1000)
    }
}
