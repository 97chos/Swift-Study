//
//  MemoListViewController.swift
//  NumberUpDown&Memo
//
//  Created by 조상호 on 2020/11/06.
//  Copyright © 2020 조상호. All rights reserved.
//

import UIKit

class MemoListViewController: UIViewController {
    
    var data = [String]()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.reloadData()
    }
    
    @IBAction func add(_ sender: Any) {
        data.append("")
        tableView.reloadData()
        (tableView.visibleCells.last as? customCell)?.textField.becomeFirstResponder()
    }
}

extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! customCell
        // 질문
        cell.textInputtedHandler = { text in
            if text != nil {
                self.data[indexPath.row] = text!
                UserDefaults.standard.set(self.data[indexPath.row], forKey: String(indexPath.row))
            } else {
                return
            }
        }
        cell.textField.text = self.data[indexPath.row]
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


