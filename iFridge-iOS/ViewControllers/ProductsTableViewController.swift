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

    fileprivate enum Segue: String {

        case productDetails = "ProductDetailsSegue"
        case logIn = "LogInSegue"
    }

    fileprivate var products: [Product] = []
    fileprivate var selectedProduct: Product?

    private var authenticator: Authenticator {
        return UIApplication.appDelegate.authenticator
    }

    private let syncManager = SyncManager()
    private let productsManager = ProductsDBManager()

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard self.authenticator.token != nil else {

            self.performLogOut()
            return
        }

        self.getProducts()
    }

    // MARK: - Actions

    @IBAction func addProductButtonWasPressed(_ sender: UIBarButtonItem) {

        guard self.authenticator.token != nil else {

            self.performLogOut()
            return
        }

        self.performSegue(withIdentifier: Segue.productDetails.rawValue, sender: self)
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

        self.products = self.productsManager.getAll()
        self.tableView.reloadData()
    }

    private func deleteProduct(productID: Int) {

        self.productsManager.delete(productId: productID)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == Segue.productDetails.rawValue) {

            guard let vc = segue.destination as? ProductDetailsTableViewController else { return }
            vc.product = self.selectedProduct
            vc.authenticator = self.authenticator
            vc.productsManager = self.productsManager
            self.selectedProduct = nil
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
        cell.quantityLabel.text = "\(product.quantity)"

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.selectedProduct = products[indexPath.row]
        self.performSegue(withIdentifier: Segue.productDetails.rawValue, sender: self)
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
