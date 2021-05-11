//
//  RoundedButton.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/07.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAttribute()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAttribute()
    }

    private func setAttribute() {
        self.cornerRadius = 15
    }
}
