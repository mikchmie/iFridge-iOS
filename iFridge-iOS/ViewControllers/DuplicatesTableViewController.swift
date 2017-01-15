//
//  DuplicatesTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 13.01.2017.
//  Copyright © 2017 MC. All rights reserved.
//

import UIKit

class DuplicatesTableViewController: UITableViewController {

    private enum Segue: String {

        case editProduct = "EditProductSegue"
    }

    var parentProduct: Product!
    var productsManager: ProductsDBManager!

    private var products: [Product] = []
    private var selectedProduct: Product?

    // MARK: - View flow

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.getProducts()
    }

    // MARK: - Products managment

    private func getProducts() {

        self.parentProduct = self.productsManager.get(by: self.parentProduct.id)
        let allProducts = self.productsManager.getAll()

        self.products = [self.parentProduct]
        self.products.append(contentsOf: allProducts.filter({ $0.duplicatesID == self.parentProduct.id }))

        self.tableView.reloadData()
    }

    private func deleteProduct(productID: Int) {

        self.productsManager.delete(productId: productID)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier ?? "" {

        case Segue.editProduct.rawValue:

            guard let vc = segue.destination as? EditProductTableViewController else { return }
            vc.product = self.selectedProduct
            vc.productsManager = self.productsManager
            self.selectedProduct = nil

        default:
            break
        }
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
        cell.nameLabel.font = (indexPath.row == 0 ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17))

        cell.shopLabel.text = product.shop

        let totalQuantity = product.quantities.reduce(0, { (result, dictPair) -> Int in
            result + dictPair.value
        })
        
        cell.quantityLabel.text = "\(totalQuantity)"
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedProduct = products[indexPath.row]
        self.performSegue(withIdentifier: Segue.editProduct.rawValue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Usuń") { (action, indexPath) in
            
            guard indexPath.row < self.products.count else { return }
            
            let productID = self.products[indexPath.row].id
            self.products.remove(at: indexPath.row)
            
            self.deleteProduct(productID: productID)

            if indexPath.row == 0 {

                if self.products.count >= 2 {
                    self.parentProduct = self.products.first
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }

            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        
        return [deleteAction]
    }
}

