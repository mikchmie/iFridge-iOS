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

    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.getProducts()
    }

    // MARK: - Actions

    @IBAction func refreshButtonWasPressed(_ sender: AnyObject) {
        self.getProducts()
    }

    // MARK: - Products download

    func getProducts() {

        FridgeApiProvider.request(.getAllProducts) { (result) in

            switch result {

            case .success(let response):

                print(response)

                do {
                    self.products = try unbox(data: response.data)
                }
                catch {
                    print(error)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else {
            //tableView.dequeueReusableCell(ProductTableViewCell.self) else {
            return UITableViewCell()
        }

        let product = self.products[indexPath.row]

        cell.nameLabel.text = product.name
        cell.shopLabel.text = product.shop
        cell.quantityLabel.text = "\(product.quantity)"

        return cell
    }
}
