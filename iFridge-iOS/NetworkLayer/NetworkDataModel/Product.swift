//
//  Product.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 08.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import Unbox
import Wrap

struct Product: Unboxable {

    var id: Int
    var name: String = ""
    var shop: String = ""
    var quantities: [String: Int] = [:]
    var duplicatesID: Int? = nil

    init(id: Int = 0, name: String = "", shop: String = "", quantities: [String: Int] = [:], duplicatesID: Int? = nil) {

        self.id = id
        self.name = name
        self.shop = shop
        self.quantities = quantities
        self.duplicatesID = duplicatesID
    }

    init(unboxer: Unboxer) throws {

        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.shop = try unboxer.unbox(key: "shop")
        self.quantities = try unboxer.unbox(key: "quantities")
        self.duplicatesID = unboxer.unbox(key: "duplicatesID")
    }

}
