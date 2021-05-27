//
//  UITableView+.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/27.
//

import UIKit

extension UITableView {
    func dequeue<T: UITableViewCell>(_ type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell")
        }
        return cell
    }
}
