//
//  FridgeApiResponse.swift
//  iFridge-iOS
//
//  Created by Mikołaj on 15.10.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import Unbox

struct Response<T: Unboxable>: Unboxable {

    let code: Int
    let value: [T]?

    init(unboxer: Unboxer) throws {

        self.code = try unboxer.unbox(key: "code")
        self.value = unboxer.unbox(key: "value")
    }
}

struct StringResponse: Unboxable {

    let code: Int
    let value: String?

    init(unboxer: Unboxer) throws {

        self.code = try unboxer.unbox(key: "code")
        self.value = unboxer.unbox(key: "value")
    }
}
