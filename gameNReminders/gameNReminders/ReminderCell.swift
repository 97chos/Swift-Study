//
//  ReminderCell.swift
//  gameNReminders
//
//  Created by sangho Cho on 2020/11/16.
//

import Foundation
import UIKit
import SnapKit

class ReminderCell: UITableViewCell {
    var tf = UITextField()
    var textInputedHandler: ((String?) -> Void)? = nil

    func tfLayout() {
        tf.delegate = self
        contentView.addSubview(tf)

        tf.snp.makeConstraints() {
            $0.top.equalTo(self.snp.top)
            $0.bottom.equalTo(self.snp.bottom)
            $0.leading.equalTo(self.snp.leading).offset(20)
            $0.trailing.equalTo(self.snp.trailing).offset(-20)
        }
    }
}

extension ReminderCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textInputedHandler?(textField.text!)
        return true
    }
}

