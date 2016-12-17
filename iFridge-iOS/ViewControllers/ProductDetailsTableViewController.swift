//
//  ProductDetailsTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class ProductDetailsTableViewController: UITableViewController {

    var product: Product!
    var authenticator: Authenticator!
    var productsManager: ProductsDBManager!
    var isNewProduct: Bool {
        return self.product.id == Int(ProductsDBManager.NoID)
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shopTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.product == nil {

            self.product = Product(id: Int(ProductsDBManager.NoID))
        }

        let navigationBar = UINavigationBar()
        let barHeight = 44.0 + UIApplication.shared.statusBarFrame.height
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barHeight)
        navigationBar.items = [self.navigationItem]
        self.tableView.tableHeaderView = navigationBar
        self.tableView.isScrollEnabled = false
        self.tableView.allowsSelection = false

        self.nameTextField.text = self.product.name
        self.nameTextField.isEnabled = self.isNewProduct
        self.shopTextField.text = self.product.shop
        self.shopTextField.isEnabled = self.isNewProduct
        self.quantityTextField.text = "\(self.product.quantity)"
        self.quantityTextField.isEnabled = self.isNewProduct
        self.quantityStepper.value = Double(self.product.quantity)
    }

    // MARK: - Actions

    @IBAction func quantityStepperValueChanged(_ sender: UIStepper) {

        self.quantityTextField.text = "\(Int(sender.value))"
    }

    @IBAction func quantityTextFieldEditingChanged(_ sender: UITextField) {

        self.quantityStepper.value = Double(sender.text ?? "") ?? self.quantityStepper.value
    }

    @IBAction func cancelButtonWasPressed(_ sender: AnyObject) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonWasPressed(_ sender: AnyObject) {

        self.product.name = self.nameTextField.text ?? ""
        self.product.shop = self.shopTextField.text ?? ""
        self.product.quantity = Int(self.quantityStepper.value)

        self.saveProduct()
    }

    // MARK: - Saving product

    func saveProduct() {

        if self.isNewProduct == true {

            self.productsManager.add(localProduct: self.product)

            self.dismiss(animated: true, completion: nil)

        } else {

            do {
                try self.productsManager.update(with: self.product)

                self.dismiss(animated: true, completion: nil)

            } catch {

                self.displayDefaultAlertView(title: "Błąd", message: "Nie udało się zapisać zmian.")
            }
        }
    }
}

