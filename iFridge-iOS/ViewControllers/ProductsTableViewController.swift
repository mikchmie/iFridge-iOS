//
//  ProductsTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 07.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit
import Unbox

class ProductsTableViewController: UITableViewController {

    private enum Segue: String {

        case addProduct = "AddProductSegue"
        case editProduct = "EditProductSegue"
        case listDuplicates = "DuplicatesListSegue"
        case logIn = "LogInSegue"
    }

    private var allProducts: [Product] = []
    private var products: [Product] = []
    private var selectedProduct: Product?

    private var authenticator: Authenticator {
        return UIApplication.appDelegate.authenticator
    }

    private let syncManager = SyncManager()
    private let productsManager = ProductsDBManager()

    // MARK: - View flow

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.getProducts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard self.authenticator.token != nil else {

            self.performLogOut()
            return
        }
    }

    // MARK: - Actions

    @IBAction func addProductButtonWasPressed(_ sender: UIBarButtonItem) {

        guard self.authenticator.token != nil else {

            self.performLogOut()
            return
        }

        self.performSegue(withIdentifier: Segue.addProduct.rawValue, sender: self)
    }

    @IBAction func logOutButtonWasPressed(_ sender: UIBarButtonItem) {

        self.performLogOut()
    }

    @IBAction func refreshControlWasTriggered(_ sender: UIRefreshControl) {

        self.syncProducts()
    }

    @IBAction func refreshButtonWasPressed(_ sender: UIBarButtonItem) {

        self.syncProducts()
    }

    // MARK: - Products managment

    private func syncProducts() {

        let commonCompletion = {

            if let refreshControl = self.refreshControl,
                refreshControl.isRefreshing == true {

                refreshControl.endRefreshing()
            }
        }

        guard let token = self.authenticator.token else {

            commonCompletion()

            return
        }

        self.syncManager.sync(token: token, completion: {

            commonCompletion()
            self.getProducts()

        }, failure: { error in

            commonCompletion()
            print(error)

            if case FridgeApiError.invalidResponseCode(401) = error {

                self.performLogOut()

            } else {

                self.displayDefaultAlertView(title: "Błąd",
                                             message: "Nie udało się zsynchronizować listy produktów. Sprawdź czy masz połączenie z internetem lub spróbuj ponownie później.")
            }
        })
    }

    private func getProducts() {

        self.allProducts = self.productsManager.getAll()
        self.products = self.allProducts.filter({ $0.duplicatesID == nil })
        self.tableView.reloadData()
    }

    private func deleteProduct(productID: Int) {

        self.productsManager.delete(productId: productID, shouldCascadeDuplicates: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier ?? "" {

        case Segue.addProduct.rawValue:

            guard let vc = segue.destination as? AddProductTableViewController else { return }
            vc.productsManager = self.productsManager
            vc.possibleDuplicates = self.products

        case Segue.editProduct.rawValue:

            guard let vc = segue.destination as? EditProductTableViewController else { return }
            vc.product = self.selectedProduct
            vc.productsManager = self.productsManager
            self.selectedProduct = nil

        case Segue.listDuplicates.rawValue:

            guard let vc = segue.destination as? DuplicatesTableViewController,
                  let product = self.selectedProduct else { return }

            vc.parentProduct = product
            vc.productsManager = self.productsManager

        default:
            break
        }
    }

    private func performLogOut() {

        self.authenticator.logOut()
        self.productsManager.deleteAllEntities()
        self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(ProductTableViewCell.self) else {
            return UITableViewCell()
        }

        let product = self.products[indexPath.row]

        cell.nameLabel.text = product.name
        cell.shopLabel.text = product.shop

        var totalQuantity = product.quantities.reduce(0, { (result, dictPair) -> Int in
            result + dictPair.value
        })

        self.allProducts.forEach {

            if $0.duplicatesID == product.id {

                totalQuantity += $0.quantities.reduce(0, { (result, dictPair) -> Int in
                    result + dictPair.value
                })
            }
        }

        cell.quantityLabel.text = "\(totalQuantity)"

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedProduct = products[indexPath.row]
        self.selectedProduct = selectedProduct

        if self.allProducts.filter({ $0.duplicatesID == selectedProduct.id }).count == 0 {

            self.performSegue(withIdentifier: Segue.editProduct.rawValue, sender: self)

        } else {

            self.performSegue(withIdentifier: Segue.listDuplicates.rawValue, sender: self)
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Usuń") { (action, indexPath) in

            guard indexPath.row < self.products.count else { return }

            let productID = self.products[indexPath.row].id
            self.products.remove(at: indexPath.row)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)

            self.deleteProduct(productID: productID)
        }

        return [deleteAction]
    }
}
