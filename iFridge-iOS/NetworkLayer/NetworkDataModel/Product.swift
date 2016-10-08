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
    var name: String
    var shop: String
    var quantity: Int

    init(unboxer: Unboxer) throws {

        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.shop = try unboxer.unbox(key: "shop")
        self.quantity = try unboxer.unbox(key: "quantity")
    }

}
//
//struct ProductList: Unboxable {
//
//    var products: [Product]
//
//    init(unboxer: Unboxer) throws {
//        self.products
//    }
//}
