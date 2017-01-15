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

    func initialize(from localProduct: Product, in moc: NSManagedObjectContext) {

        self.productId = Int32(localProduct.id)
        self.name = localProduct.name
        self.shop = localProduct.shop

        if let duplicatesID = localProduct.duplicatesID {
            self.duplicatesID = NSNumber(value: duplicatesID)
        }

        for (deviceID, quantity) in localProduct.quantities {

            let cdQuantity = CDProductQuantity(context: moc)
            cdQuantity.deviceId = deviceID
            cdQuantity.quantity = Int32(quantity)
            self.addToQuantities(cdQuantity)
        }
    }

    static func localProduct(from cdProduct: CDProduct) -> Product {

        var quantities = [String: Int]()
        for cdQuantity in (cdProduct.quantities?.allObjects as? [CDProductQuantity]) ?? [] {

            quantities[cdQuantity.deviceId ?? ""] = Int(cdQuantity.quantity)
        }

        return Product(id: Int(cdProduct.productId),
                       name: cdProduct.name ?? "",
                       shop: cdProduct.shop ?? "",
                       quantities: quantities,
                       duplicatesID: cdProduct.duplicatesID?.intValue,
                       shouldCascadeDuplicates: cdProduct.shouldCascadeDuplicates)
    }

}
