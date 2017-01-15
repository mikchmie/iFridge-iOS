//
//  AddProductTableViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class AddProductTableViewController: UITableViewController, UIPickerViewDelegate {

    var productsManager: ProductsDBManager!
    var possibleDuplicates: [Product] = []

    private var product = Product(id: Int(ProductsDBManager.NoID))

    private var deviceID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shopTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var duplicateSwitch: UISwitch!
    @IBOutlet weak var duplicatePickerView: UIPickerView!

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

        self.duplicatePickerView.delegate = self

        self.nameTextField.text = self.product.name
        self.shopTextField.text = self.product.shop

        self.quantityTextField.text = "\(1)"
        self.quantityStepper.value = 1
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
        self.product.quantities[self.deviceID] = Int(self.quantityStepper.value)

        let duplicateRow = self.duplicatePickerView.selectedRow(inComponent: 0)
        if self.duplicateSwitch.isOn == true && duplicateRow != -1 {

            let duplicate = self.possibleDuplicates[duplicateRow]
            self.product.duplicatesID = duplicate.id
        }

        [self.nameTextField, self.shopTextField, self.quantityTextField].forEach {
            $0.resignFirstResponder()
        }

        self.saveProduct()
    }

    @IBAction func duplicateSwitchValueChanged(_ sender: UISwitch) {

        self.duplicatePickerView.isUserInteractionEnabled = sender.isOn
        self.duplicatePickerView.alpha = sender.isOn ? 1.0 : 0.5

        if self.possibleDuplicates.count > 0 {

            self.duplicatePickerView.selectedRow(inComponent: 0)
        }
    }

    // MARK: - Saving product

    func saveProduct() {

        self.productsManager.add(localProduct: self.product)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Picker view delegate

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return self.possibleDuplicates.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return self.possibleDuplicates[row].name
    }
}

