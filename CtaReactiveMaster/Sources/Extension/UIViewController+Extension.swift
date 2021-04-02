//
//  UIViewController+Extension.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/06.
//

import UIKit

extension UIViewController {
    func showRetryAlert(with error: Error, retryhandler: @escaping () -> ()) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            retryhandler()
        })
        present(alertController, animated: true, completion: nil)
    }
}
