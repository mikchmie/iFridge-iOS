//
//  SyncManager.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 11.12.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import UIKit

enum SyncError: Error {

    case missingToken
}

class SyncManager {

    // MARK: - Properties

    private static let LastSyncKey = "LastSyncKey"

    private(set) var lastSyncTimestamp: Int {
        didSet {
            UserDefaults.standard.setValue(self.lastSyncTimestamp, forKey: SyncManager.LastSyncKey)
        }
    }

    private let dbManager = ProductsDBManager()

    // MARK: - Initialization

    init() {

        self.lastSyncTimestamp = UserDefaults.standard.integer(forKey: SyncManager.LastSyncKey)
    }

    // MARK: - Sync

    func sync(token: String, completion: @escaping () -> Void, failure: ((Error) -> Void)?) {

        let productsForDeletion = self.dbManager.getMarkedForDeletion().map(CDProduct.localProduct)
        let productsModified = self.dbManager.getModified(after: self.lastSyncTimestamp).map(CDProduct.localProduct)
        let productsNew = self.dbManager.getNew().map(CDProduct.localProduct)

        self.performDeletions(products: productsForDeletion, token: token, completion: {

            self.performUpdates(products: productsModified, token: token, completion: {

                self.performAdditions(products: productsNew, token: token, completion: {

                    self.downloadAll(token: token, completion: { (brandNewProducts) in

                        self.dbUpdate(brandNewProducts: brandNewProducts)
                        self.lastSyncTimestamp = Date().timestamp
                        completion()

                    }, failure: failure)

                }, failure: failure)

            }, failure: failure)

        }, failure: failure)
    }

    // MARK: - Sync phases

    private func performDeletions(products: [Product], token: String, completion: @escaping () -> Void, failure: ((Error) -> Void)?) {

        guard let product = products.first else {
            completion()
            return
        }

        FridgeApi.performDeleteProduct(productID: product.id, token: token, completion: {

            var remainingProducts = products
            remainingProducts.removeFirst()

            self.performDeletions(products: remainingProducts, token: token, completion: completion, failure: failure)

        }, failure: failure)
    }

    private func performUpdates(products: [Product], token: String, completion: @escaping () -> Void, failure: ((Error) -> Void)?) {

        guard let product = products.first else {
            completion()
            return
        }

        FridgeApi.performUpdateProduct(product: product, token: token, completion: { (_) in

            var remainingProducts = products
            remainingProducts.removeFirst()

            self.performUpdates(products: remainingProducts, token: token, completion: completion, failure: failure)
            
        }, failure: failure)
    }

    private func performAdditions(products: [Product], token: String, completion: @escaping () -> Void, failure: ((Error) -> Void)?) {

        guard let product = products.first else {
            completion()
            return
        }

        FridgeApi.performAddProduct(product: product, token: token, completion: { (_) in

            var remainingProducts = products
            remainingProducts.removeFirst()

            self.performAdditions(products: remainingProducts, token: token, completion: completion, failure: failure)
            
        }, failure: failure)
    }

    private func downloadAll(token: String, completion: @escaping ([Product]) -> Void, failure: ((Error) -> Void)?) {

        FridgeApi.performGetAllProducts(token: token, completion: { (products) in

            completion(products)

        }, failure: failure)
    }

    private func dbUpdate(brandNewProducts: [Product]) {

        self.dbManager.deleteAllEntities()
        self.dbManager.add(remoteProducts: brandNewProducts)
    }
}
