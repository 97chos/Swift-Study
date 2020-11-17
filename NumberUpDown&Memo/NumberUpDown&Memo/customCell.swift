//
//  customCell.swift
//  NumberUpDown&Memo
//
//  Created by sangho Cho on 2020/11/08.
//  Copyright © 2020 조상호. All rights reserved.
//

import Foundation
import UIKit

class customCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!

    var textInputtedHandler: ((String?) -> Void)? = nil
}

extension customCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textInputtedHandler?(textField.text)
        return true
    }
}
