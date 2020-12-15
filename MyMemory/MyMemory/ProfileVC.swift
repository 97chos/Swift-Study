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

        // 탭 제스처 추가
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        // 해당 객체가 사용자와 상호작용 할 수 있도록 속성 설정
        self.profileImage.isUserInteractionEnabled = true
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
                self.profileImage.image = self.uInfo.profile            // 추가 이미지 프로필 갱신
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension ProfileVC: UIImagePickerControllerDelegate {

    // 이미지 피커 컨트롤러 띄우는 메소드
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }

    // 프로필 사진의 소스 타입을 선택하는 액션 메소드
    @objc func profile(_ sender : UIButton) {
        // 로그인되어 있지 않을 경우에는 프로필 이미지 등록을 막고 대신 로그인 창을 띄워준다.
        guard self.uInfo.isLogin == true else {
            self.doLogin(self)
            return
        }

        let alert = UIAlertController(title: nil,
                                      message: "사진을 가져올 곳을 선택하세요",
                                      preferredStyle: .actionSheet)

        // 카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) {_ in
                self.imgPicker(.camera)
            })
        }
        // 저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "앨범", style: .default){ _ in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){ _ in
                self.imgPicker(.photoLibrary)
            })
        }
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .default))

        // 액션 시트 실행
        self.present(alert, animated: true)
    }

    // 이미지 선택 시 자동으로 호출되는 델리게이트 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uInfo.profile = img
            self.profileImage.image = img
        }
        picker.dismiss(animated: true)
    }
}

extension ProfileVC: UINavigationControllerDelegate {
    @IBAction func backProfile(_ segue: UIStoryboardSegue) {
        
    }

}
