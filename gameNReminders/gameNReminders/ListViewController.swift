//
//  ViewController.swift
//  gameNReminders
//
//  Created by sangho Cho on 2020/11/14.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {

    var list = ["NumberGame","Reminders"]

    var tableview = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableview = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.white
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationItem.title = "List"
        view.addSubview(tableview)
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = list[indexPath.row]
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let gvc = NumberGame()
            self.navigationController?.pushViewController(gvc, animated: true)
        } else if indexPath.row == 1 {
            let mvc = RemindersViewController()
            self.navigationController?.pushViewController(mvc, animated: true)
        }
    }
}
