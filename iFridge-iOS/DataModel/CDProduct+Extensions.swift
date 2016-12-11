//
//  CDProduct+Extensions.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 11.12.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import CoreData

extension CDProduct {

    func toLocalProduct() -> Product {

        return CDProduct.localProduct(from: self)
    }

    func update(from localProduct: Product) {

        self.productId = Int32(localProduct.id)
        self.name = localProduct.name
        self.shop = localProduct.shop
        self.quantity = Int32(localProduct.quantity)
        self.modifiedAt = Int64(localProduct.modifiedAt)
    }

    static func localProduct(from cdProduct: CDProduct) -> Product {

        return Product(id: Int(cdProduct.productId),
                       name: cdProduct.name ?? "",
                       shop: cdProduct.shop ?? "",
                       quantity: Int(cdProduct.quantity),
                       modifiedAt: Int(cdProduct.modifiedAt))
    }

}
