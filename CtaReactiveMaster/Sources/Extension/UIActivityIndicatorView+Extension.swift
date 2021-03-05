//
//  UIActivityIndicator+Extension.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/05.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIActivityIndicatorView {
    var startAnimazing: Binder<Void> {
        Binder(self.base){ base, _ in
            base.startAnimating()
        }
    }
    
    var stopAnimazing: Binder<Void> {
        Binder(self.base){ base, _ in
            if base.isAnimating {
                base.stopAnimating()
            }
        }
    }
}
