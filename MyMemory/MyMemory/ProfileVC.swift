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
    let uInfo = UserInfoManager()       // 개인 정보 관리 매니저

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
        let image = self.uInfo.profile

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
        drawBtn()
    }

    //MARK: - 창 닫기 메소드
    @objc func close(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }

    //MARK: - 로그인 창 표시 메소드
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)

        // 알림창에 들어갈 입력폼 추가
        loginAlert.addTextField() { tf in
            tf.placeholder = "Your Account"
        }
        loginAlert.addTextField() { tf in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }

        // 알림창 버튼 추가
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .default){ _ in
            let account = loginAlert.textFields?[0].text ?? ""
            let passwd = loginAlert.textFields?[1].text ?? ""

            if self.uInfo.login(account: account, passwd: passwd) {
                self.tv.reloadData()                                    // 테이블 뷰 갱신
                self.profileImage.image = self.uInfo.profile           // 추가 이미지 프로필 갱신
                self.drawBtn()
            } else {
                let msg = "로그인에 실패하였습니다."
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style:.default))
                self.present(alert, animated: true)
            }
        })
        self.present(loginAlert, animated: true)
    }
    //MARK: - 로그아웃 메소드
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            if self.uInfo.logout() {
                self.tv.reloadData()
                self.profileImage.image = self.uInfo.profile        // 이미지 프로필 갱신
                self.drawBtn()
            }
        })
        self.present(alert, animated: true)
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
            cell.detailTextLabel?.text = self.uInfo.name ?? "Login Please"
        case 1 :
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.uInfo.account ?? "Login Please"
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uInfo.isLogin == false {
            // 로그인이 안되어 있으면 로그인 창 실행
            self.doLogin(self.tv)
        }
    }
    //MARK: - 로그인/로그아웃 버튼 메소드
    func drawBtn() {
        // 버튼을 감쌀 뷰 정의
        let v = UIView()
        v.frame.origin = CGPoint(x: 0, y: self.tv.frame.origin.y + self.tv.frame.size.height)
        v.frame.size = CGSize(width: self.view.frame.width, height: 40)
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)

        self.view.addSubview(v)

        // 버튼 정의
        let btn = UIButton(type: .system)
        btn.frame.size = CGSize(width: 100, height: 30)
        btn.center.x = v.frame.width / 2
        btn.center.y = v.frame.height / 2

        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때는 로그인 버튼을 생성
        if self.uInfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)

    }
}

extension ProfileVC: UITableViewDataSource {

}
