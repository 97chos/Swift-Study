//
//  SideBarVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/01.
//

import Foundation
import UIKit

class SideBarVC: UITableViewController {

    // 목록 데이터 배열
    let titles = ["새 글 작성하기","친구 새 글","달력으로 보기","공지사항","통계","계정 관리"]

    // 아이콘 데이터 배열
    let icons = [
        UIImage(named: "icon01"),
        UIImage(named: "icon02"),
        UIImage(named: "icon03"),
        UIImage(named: "icon04"),
        UIImage(named: "icon05"),
        UIImage(named: "icon06")
    ]

    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()

    // 개인 정보 관리 매니저
    let uInfo = UserInfoManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 헤더뷰 생성
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = .brown
        self.tableView.tableHeaderView = headerView

        // 이름 레이블 속성 설정
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.nameLabel.textColor = .white
        self.nameLabel.font = .boldSystemFont(ofSize: 15)
        self.nameLabel.backgroundColor = .clear

        // 이메일 레이블 속성 설정
        self.emailLabel.frame = CGRect(x: 70, y: 40, width: 100, height: 30)
        self.emailLabel.textColor = .white
        self.emailLabel.font = .systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear

        // 기본 프로필 이미지 구현
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)

        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2    // 반원 형태로 라운딩
        self.profileImage.layer.borderWidth = 0                                     // 테두리 두께 0
        self.profileImage.layer.masksToBounds = true                                // 마스크 효과로 가려진 이미지 반전 처리

        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        headerView.addSubview(profileImage)

        self.tableView.tableFooterView = UIView()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.nameLabel.text = self.uInfo.name ?? "Guest"
        self.emailLabel.text = self.uInfo.account ?? ""
        self.emailLabel.sizeToFit()
        self.profileImage.image = self.uInfo.profile
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "menucell"

        // 재사용 큐에서 테이블 셀을 꺼내 온다. 없으면 새로 생성한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default,
                                                                                        reuseIdentifier: id)
        // 타이틀과 이미지를 대입한다.
        cell.textLabel?.text = titles[indexPath.row]
        cell.imageView?.image = icons[indexPath.row]

        // 폰트 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 선택된 행이 새 글 작성 메뉴일 때
        if titles[indexPath.row] == "새 글 작성하기" {
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "Memoform")
            // revealViewController() 메소드는 메인 컨트롤러 객체(RevealViewController)를 가져오는 메소드, 이를 통해 frontViewController(메모 목록) 컨트롤러를 간접적으로 참조, 이를 네비게이션 컨트롤러로 캐스팅하여 pushViewController 메소드 호출
            let target = self.revealViewController()?.frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            // 사이드바를 닫아주는 메소드
            self.revealViewController()?.revealToggle(self)
        } else if titles[indexPath.row] == "계정 관리" {  // 계정관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true) {
                self.revealViewController()?.revealToggle(self)
            }
        }
    }
}
