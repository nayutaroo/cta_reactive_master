//
//  RoundedButton.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/07.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cornerRadius = 15
    }
}
