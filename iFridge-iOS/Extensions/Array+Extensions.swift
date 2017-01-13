//
//  Array+Extensions.swift
//  PFC
//
//  Created by Mikołaj on 08.11.2016.
//  Copyright © 2016 inFullMobile. All rights reserved.
//

import Foundation

extension Array {

    /// Returns first element to match given predicate or nil if none matches the predicate
    func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {

        guard let index = try self.index(where: predicate) else { return nil }

        return self[index]
    }
}
