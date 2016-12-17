//
//  AddProductTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class AddProductTableViewController: UITableViewController {

    var product = Product(id: Int(ProductsDBManager.NoID))
    var productsManager: ProductsDBManager!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shopTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBar = UINavigationBar()
        let barHeight = 44.0 + UIApplication.shared.statusBarFrame.height
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barHeight)
        navigationBar.items = [self.navigationItem]
        self.tableView.tableHeaderView = navigationBar
        self.tableView.isScrollEnabled = false
        self.tableView.allowsSelection = false

        self.nameTextField.text = self.product.name
        self.shopTextField.text = self.product.shop
        self.quantityTextField.text = "\(self.product.quantity)"
        self.quantityStepper.value = Double(self.product.quantity)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.nameTextField.becomeFirstResponder()
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

        [self.nameTextField, self.shopTextField, self.quantityTextField].forEach {
            $0.resignFirstResponder()
        }

        self.saveProduct()
    }

    // MARK: - Saving product

    func saveProduct() {

        self.productsManager.add(localProduct: self.product)
        self.dismiss(animated: true, completion: nil)
    }
}

