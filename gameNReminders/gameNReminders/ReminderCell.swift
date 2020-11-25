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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tfLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var tf = UITextField()
    var textInputedHandler: ((String?) -> Void)? = nil

    func tfLayout() {
        contentView.addSubview(tf) //??
        tf.delegate = self
        tf.backgroundColor = .black
        tf.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tf.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tf.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tf.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}

extension ReminderCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textInputedHandler?(textField.text!)
        return true
    }
}

