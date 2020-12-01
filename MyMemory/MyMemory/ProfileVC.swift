//
//  ProfileVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/01.
//

import Foundation
import UIKit

class ProfileVC: UIViewController {

    let profileImage = UIImageView()    // 프로필 사진 이미지
    let tv = UITableView()              // 프로필 목록

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "프로필"

        // 뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기",
                                      style: .plain,
                                      target: self,
                                      action: #selector(close(_:)))

        self.navigationItem.leftBarButtonItem = backBtn

        // 프로필 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)

        bgImg.frame.size = CGSize(width: bgImg.frame.width, height: bgImg.frame.height)
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 60)

        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        self.view.addSubview(bgImg)

        // 1. 프로필 사진에 들어갈 기본 이미지
        let image = UIImage(named: "account.jpg")

        // 2. 프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 290)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true

        self.view.addSubview(profileImage)

        // 테이블 뷰
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.height + 20, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self

        self.view.addSubview(tv)
    }

    @objc func close(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }
}

extension ProfileVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")

        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator

        switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = "조상호"
        case 1 :
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = "97chos@naver.com"
        default:
            break
        }

        return cell
    }
}

extension ProfileVC: UITableViewDataSource {

}
