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

    fileprivate var authenticator: Authenticator {
        return UIApplication.appDelegate.authenticator
    }

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard self.authenticator.token != nil else {

            self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
            return
        }

        self.getProducts()
    }

    // MARK: - Actions

    @IBAction func addProductButtonWasPressed(_ sender: UIBarButtonItem) {

        guard self.authenticator.token != nil else {

            self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
            return
        }

        self.performSegue(withIdentifier: Segue.productDetails.rawValue, sender: self)
    }

    @IBAction func logOutButtonWasPressed(_ sender: UIBarButtonItem) {

        self.authenticator.logOut()
        self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
    }

    @IBAction func refreshControlWasTriggered(_ sender: UIRefreshControl) {

        guard self.authenticator.token != nil else {

            self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
            return
        }

        self.getProducts()
    }

    // MARK: - Products download

    func getProducts() {

        let handleError = { (error: Error?) in

            self.displayDefaultAlertView(title: "Błąd", message: "Nie udało się pobrać listy produktów. Sprawdź czy masz połączenie z internetem lub spróbuj ponownie później.")

            if let error = error {
                print(error)
            }
        }

        guard let token = self.authenticator.token else {
            handleError(nil)
            return
        }

        FridgeApiProvider.request(.getAllProducts(token: token)) { (result) in

            DispatchQueue.main.async {
                if let refreshControl = self.refreshControl,
                    refreshControl.isRefreshing == true {

                    refreshControl.endRefreshing()
                }
            }

            switch result {

            case .success(let response):

                print(String(data: response.data, encoding: .utf8))

                guard response.statusCode != 401 else {

                    DispatchQueue.main.async {
                        self.authenticator.logOut()
                        self.performSegue(withIdentifier: Segue.logIn.rawValue, sender: self)
                    }

                    return
                }

                do {
                    self.products = try unbox(data: response.data)
                }
                catch {
                    handleError(error)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):

                handleError(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == Segue.productDetails.rawValue) {

            guard let vc = segue.destination as? ProductDetailsTableViewController else { return }
            vc.product = self.selectedProduct
            self.selectedProduct = nil
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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
}
