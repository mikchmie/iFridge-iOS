//
//  Product.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 08.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

struct Product: Codable {

    var id: Int = 0
    var name: String = ""
    var shop: String = ""
    var quantities: [String: Int] = [:]
    var duplicatesID: Int? = nil
    var shouldCascadeDuplicates: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shop
        case quantities
        case duplicatesID
    }
    
}
