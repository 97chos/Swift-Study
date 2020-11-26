//
//  MemoListVCTableViewController.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/11/25.
//

import UIKit

class MemoListVC: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.memoList.count
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. memoList 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memoList[indexPath.row]

        // 2. 이미지 속성이 비어 있을 경우 "memocell", 아니면 "memocellWithImage"
        let cellId = row.image == nil ? "memoCell" : "memoCellWithImage"

        // 3. 재사용 큐로부터 셀의 인스턴스를 전달받는다.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MemoCell

        // 4. memoCell의 내용을 구성한다.
        cell.subejct.text = row.title
        cell.contents.text = row.contents
        cell.img?.image = row.image

        // 5. 데이터 타입의 날짜를 yyyy-mm-dd HH:mm:ss 포맷에 맞게 변경한다.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        cell.regdate.text = formatter.string(from: row.regdate!)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.appDelegate.memoList[indexPath.row]

        guard let vc = self.storyboard?.instantiateViewController(identifier: "MemoRead") as? MemoReadVC else {
            return
        }

        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }



}
