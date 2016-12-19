//
//  AddProductTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class EditProductTableViewController: UITableViewController {

    var product: Product!
    var productsManager: ProductsDBManager!

    var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

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

        self.quantityTextField.text = "\(0)"
        self.quantityStepper.value = Double(0)
    }

    // MARK: - Actions

    @IBAction func quantityStepperValueChanged(_ sender: UIStepper) {

        self.quantityTextField.text = "\(Int(sender.value))"
    }

    @IBAction func quantityTextFieldEditingDidBegin(_ sender: UITextField) {

        sender.text = ""
    }

    @IBAction func quantityTextFieldEditingChanged(_ sender: UITextField) {

        self.quantityStepper.value = Double(sender.text ?? "") ?? self.quantityStepper.value
    }

    @IBAction func cancelButtonWasPressed(_ sender: AnyObject) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonWasPressed(_ sender: AnyObject) {

        let initialQuantity = self.product.quantities[self.deviceID] ?? 0
        self.product.quantities[self.deviceID] = initialQuantity + Int(self.quantityStepper.value)
        self.quantityTextField.resignFirstResponder()
        self.saveProduct()
    }

    // MARK: - Saving product

    func saveProduct() {

        do {
            try self.productsManager.update(with: self.product, forDevice: self.deviceID)

            self.dismiss(animated: true, completion: nil)

        } catch {

            self.displayDefaultAlertView(title: "Błąd", message: "Nie udało się zapisać zmian.")
        }
    }
}

