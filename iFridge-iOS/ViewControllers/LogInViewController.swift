//
//  LogInViewController.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    var logInInProgress: Bool = false

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logInButtonWasPressed(_ sender: UIButton) {

        guard self.logInInProgress == false else { return }

        guard let login = self.loginTextField.text,
            let password = self.passwordTextField.text else {

                self.displayDefaultAlertView(title: "Brakujące dane", message: "Aby zalogować się, podaj swój login i hasło")
                return
        }

        self.logInInProgress = true
        sender.isEnabled = false

        UIApplication.appDelegate.authenticator.logIn(login: login, password: password) { (error) in

            DispatchQueue.main.async {

                self.logInInProgress = false
                sender.isEnabled = true
            }

            if let error = error {

                switch error {

                case .invalidCredentials:
                    self.displayDefaultAlertView(title: "Błąd", message: "Podana kombinacja loginu i hasła jest nieprawidłowa")

                case .other:
                    self.displayDefaultAlertView(title: "Błąd", message: "Nie udało się zalogować. Sprawdź czy masz połączenie z internetem lub spróbuj ponownie za chwilę")
                }

                return
            }

            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
