//
//  Reminders.swift
//  gameNReminders
//
//  Created by sangho Cho on 2020/11/16.
//

import Foundation
import UIKit
import SnapKit

class RemindersViewController: UIViewController, UITableViewDelegate {

    var List = UITableView()
    var addView = UIView()
    var addbutton = UIButton()
    var data = [String]()
    

    override func viewDidLoad() {
        List = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        List.backgroundColor = .systemTeal
        List.register(ReminderCell.self, forCellReuseIdentifier: "cell")
        List.delegate = self
        List.dataSource = self
        List.tableFooterView = UIView()
        view.addSubview(List)
        view.addSubview(addView)
        view.addSubview(addbutton)
        self.title = "Reminders"
        addbutton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        addbuttonLayout()

        var n = "0"
        while UserDefaults.standard.string(forKey: n) != nil {
            if (UserDefaults.standard.string(forKey: n)!) == "" {
                UserDefaults.standard.removeObject(forKey: n)
                data.remove(at: Int(n)!)
            } else {
                data.append(UserDefaults.standard.string(forKey: n)!)
            }
            n = String(Int(n)! + 1)
        }
        List.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.List.estimatedRowHeight = 100
        self.List.rowHeight = UITableView.automaticDimension
    }

    @objc func addAction() {
        data.append("")
        List.reloadData()
        (List.visibleCells.last as? ReminderCell)?.tf.becomeFirstResponder()
    }

    func addbuttonLayout() {
        addbutton.setTitle(" New Reminder", for: .normal)
        addbutton.setTitleColor(.systemBlue, for: .normal)
        addbutton.setImage(.add, for: .normal)
        addbutton.snp.makeConstraints() {
            $0.leading.equalTo(addView.snp.leading).offset(20)
            $0.top.equalTo(addView.snp.top).offset(20)
        }
        addView.backgroundColor = .white
        addView.snp.makeConstraints() {
            $0.bottom.equalToSuperview().offset(0)
            $0.height.equalTo(70)
            $0.leading.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(0)
        }
    }
}

extension RemindersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReminderCell

        cell.textInputedHandler = { text in
            if text != nil {
                self.data[indexPath.row] = text!
                UserDefaults.standard.set(self.data[indexPath.row], forKey: String(indexPath.row))
            } else {
                return
            }
        }
        cell.tf.text = data[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.removeObject(forKey: String(indexPath.row))
        }
    }
}

