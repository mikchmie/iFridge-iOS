//
//  ProductsManager.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 11.12.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import CoreData
import Result

class ProductsDBManager {

    enum ProductError: Error {
        case notFound
    }

    // MARK: - Properties

    static let NoID: Int32 = -1

    var moc: NSManagedObjectContext = UIApplication.appDelegate.persistentContainer.viewContext

    // MARK: - Product operations

    func add(localProduct product: Product) {

        self.moc.performAndWait {

            let newProduct = CDProduct(context: self.moc)
            newProduct.update(from: product)
            newProduct.productId = ProductsDBManager.NoID
            newProduct.modifiedAt = Int64(Date().timestamp)

            do {
                try self.moc.save()
            } catch {
                print(error)
            }
        }
    }

    func add(remoteProducts products: [Product]) {

        self.moc.performAndWait {

            for product in products {

                let newProduct = CDProduct(context: self.moc)
                newProduct.update(from: product)
            }

            do {
                try self.moc.save()
            } catch {
                print(error)
            }
        }
    }

    func getAll() -> [Product] {

        let predicate = NSPredicate(format: "%K == NO", "isMarkedForDeletion")
        return self.getEntities(with: predicate).map(CDProduct.localProduct)
    }

    func get(by id: Int) -> Product? {

        do {
            return (try self.getEntity(by: id)).toLocalProduct()

        } catch is ProductError {
            return nil

        } catch {
            print(error)
            return nil
        }
    }

    func update(with product: Product) throws {

        var queryError: Error?

        self.moc.performAndWait {

            do {
                let currentProduct = try self.getEntity(by: product.id)
                currentProduct.update(from: product)
                currentProduct.modifiedAt = Int64(Date().timestamp)

                try self.moc.save()

            } catch {
                queryError = error
            }
        }

        if let error = queryError {
            throw error
        }
    }

    func delete(productId: Int) {

        self.moc.performAndWait {

            do {
                guard let currentProduct = (try? self.getEntity(by: productId)) else {
                    return
                }

                if currentProduct.productId == ProductsDBManager.NoID {

                    self.moc.delete(currentProduct)

                } else {

                    currentProduct.isMarkedForDeletion = true
                    currentProduct.modifiedAt = 0
                }

                try self.moc.save()

            } catch {
                print(error)
            }
        }
    }

    // MARK: - Sync-related queries

    func getMarkedForDeletion() -> [CDProduct] {

        let predicate = NSPredicate(format: "%K == YES", "isMarkedForDeletion")
        return self.getEntities(with: predicate)
    }

    func getModified(after timestamp: Int) -> [CDProduct] {

        let predicate = NSPredicate(format: "%K > %lld && %K != %d", "modifiedAt", timestamp, "productId", ProductsDBManager.NoID)
        return self.getEntities(with: predicate)
    }

    func getNew() -> [CDProduct] {

        let predicate = NSPredicate(format: "%K == %d", "productId", ProductsDBManager.NoID)
        return self.getEntities(with: predicate)
    }

    func deleteAllEntities() {

        self.moc.performAndWait {

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDProduct.fetchRequest())

            do {
                try self.moc.execute(deleteRequest)

            } catch {
                print(error)
            }
        }
    }

    // MARK: - Private queries

    private func getEntity(by id: Int) throws -> CDProduct {

        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %d", "productId", Int32(id))

        guard let entity = try self.moc.fetch(request).first else {

            throw ProductError.notFound
        }
        
        return entity
    }

    private func getEntities(with predicate: NSPredicate) -> [CDProduct] {

        let request: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "productId", ascending: true)]

        do {
            return try self.moc.fetch(request)

        } catch {
            print(error)
            return []
        }
    }
}
