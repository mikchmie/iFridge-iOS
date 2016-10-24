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
    var authenticator: Authenticator {
        return UIApplication.appDelegate.authenticator
    }
    var isNewProduct: Bool {
        return self.product.id == -1
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shopTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.product == nil {

            self.product = Product(id: -1)
        }

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

    }

    // MARK: - Actions

    @IBAction func quantityStepperValueChanged(_ sender: UIStepper) {

        self.quantityTextField.text = "\(Int(sender.value))"
    }

    @IBAction func quantityTextFieldValueChanged(_ sender: UITextField) {

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

        let handleError = { (error: Error?) in

            self.displayDefaultAlertView(title: "Błąd", message: "Nie udało się zapisać produktu. Sprawdź czy masz połączenie z internetem lub spróbuj ponownie później.")

            if let error = error {
                print(error)
            }
        }

        guard let token = self.authenticator.token else {
            handleError(nil)
            return
        }

        let method: FridgeApi = (self.isNewProduct == true ? .addProduct(product: self.product, token: token) :
                                                             .updateProduct(product: self.product, token: token))

        FridgeApiProvider.request(method) { (result) in

            switch result {

            case .success(let response):

                print(String(data: response.data, encoding: .utf8))

                guard response.statusCode == 200 || response.statusCode == 201 else {
                    handleError(nil)
                    return
                }

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }

            case .failure(let error):

                handleError(error)
            }
        }
    }
}

