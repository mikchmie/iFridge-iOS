//
//  Authenticator.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AuthenticationError: Error {

    case invalidCredentials, other
}

class Authenticator {

    fileprivate static let TokenKey = "FridgeApiToken"

    init() {

        self.token = UserDefaults.standard.string(forKey: Authenticator.TokenKey)
    }

    fileprivate(set) var token: String? {
        didSet {
            UserDefaults.standard.setValue(self.token, forKey: Authenticator.TokenKey)
        }
    }

    func logIn(login: String, password: String, completion: @escaping (AuthenticationError?) -> Void) {

        let passwordHash = password.sha256

        FridgeApiProvider.request(.logIn(login: login, password: passwordHash)) { (result) in

            switch result {

            case .success(let response):

                print(String(data: response.data, encoding: .utf8) ?? "")

                guard response.statusCode == 200 else {

                    completion(response.statusCode == 401 ? .invalidCredentials : .other)
                    return
                }

                guard let token = String(data: response.data, encoding: .utf8) else {

                    completion(.other)
                    return
                }

                self.token = token
                completion(nil)

            case .failure(let error):

                print(error)
                completion(.other)
                return
            }
        }
    }

    func logOut() {

        self.token = nil
    }
}
