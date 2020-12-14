//
//  MemoListVCTableViewController.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/11/25.
//

import UIKit

class MemoListVC: UITableViewController {

    lazy var dao = MemoDAO()

    // 앱 델리게이트 참조 정보 읽어오기
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // SWRevealViewController 라이브러리의 revealViewController 객체를 읽어온다.
        if let revealVC = self.revealViewController() {

            // 바 버튼 아이템 객체를 정의한다.
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC                                       // 버튼 클릭 시 호출할 메소드가 정의된 객체를 지정
            btn.action = #selector(revealVC.revealToggle(animated:))    // 버튼 클릭 시 revealToggle(animated:) 메소드 호출

            // 정의된 바 버튼을 내비게이션 바의 왼쪽 아이템으로 등록한다.
            self.navigationItem.leftBarButtonItem = btn

            // 제스처 객체 등록
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        // 코어 데이터에 저장된 데이터를 가져온다.
        self.appDelegate.memoList = self.dao.fetch()
        
        self.tableView.reloadData()

        // 이전에 튜토리얼 화면 확인 여부 체크
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true)
            return
        }
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

    // 편집 모드 지정
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let data = self.appDelegate.memoList[indexPath.row]

        // 코어 데이터에서 삭제한 다음, 배열 내 데이터 및 테이블 뷰 행을 차례로 삭제
        if dao.delete(data.objectID!) {
            self.appDelegate.memoList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
