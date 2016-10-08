//
//  ReusableView.swift
//  PFC
//
//  Created by Mikołaj on 07.09.2016.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

protocol ReusableView: class {

    static var defaultReusableIdentifier: String { get }
}

extension ReusableView where Self: UIView {

    static var defaultReusableIdentifier: String {
        get {
            return String(describing: type(of: self))
        }
    }
}

extension UITableViewCell: ReusableView {}
extension UITableViewHeaderFooterView: ReusableView {}
extension UICollectionReusableView: ReusableView {}

extension UITableView {

    convenience init(cellClasses: [ReusableView.Type], headerFooterClasses: [ReusableView.Type]) {

        self.init()

        cellClasses.forEach {
            self.register($0, forCellReuseIdentifier: $0.defaultReusableIdentifier)
        }

        headerFooterClasses.forEach {
            self.register($0, forHeaderFooterViewReuseIdentifier: $0.defaultReusableIdentifier)
        }

    }

    func dequeueReusableCell<T: ReusableView>(_ cellType: T.Type) -> T? {

        let id = cellType.defaultReusableIdentifier
        return self.dequeueReusableCell(withIdentifier: id) as? T
    }

    func dequeueReusableHeaderFooterView<T: ReusableView>(_ cellType: T.Type) -> T? {

        return self.dequeueReusableHeaderFooterView(withIdentifier: cellType.defaultReusableIdentifier) as? T
    }
}

extension UICollectionView {

    convenience init(cellClasses: [ReusableView.Type], supplementaryViewClassesWithKinds: [(ReusableView.Type, String)]) {

        self.init()

        cellClasses.forEach {
            self.register($0, forCellWithReuseIdentifier: $0.defaultReusableIdentifier)
        }

        supplementaryViewClassesWithKinds.forEach {
            self.register($0.0, forSupplementaryViewOfKind: $0.1, withReuseIdentifier: $0.0.defaultReusableIdentifier)
        }
    }

    func dequeueReusableCell<T: ReusableView>(_ cellType: T.Type, forIndexPath indexPath: IndexPath) -> T? {

        return self.dequeueReusableCell(withReuseIdentifier: cellType.defaultReusableIdentifier, for: indexPath) as? T
    }

    func dequeueReusableHeaderFooterView<T: ReusableView>(_ cellType: T.Type, elementKind: String,
                                         forIndexPath indexPath: IndexPath) -> T? {

        return self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: cellType.defaultReusableIdentifier,
                                                     for: indexPath) as? T
    }
}
