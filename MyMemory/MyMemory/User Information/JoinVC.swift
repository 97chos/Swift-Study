//
//  JoinVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/15.
//

import Foundation
import UIKit
import Alamofire

class JoinVC: UIViewController {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var indicator: UIActivityIndicatorView!

    // API 호출 상태값을 관리할 변수
    var isCalling = false

    // API로 신규 유저 데이터 전송
    @IBAction func submit(_ sender: Any) {
        if self.isCalling == true {
            self.alert("진행 중입니다. 잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }

        // 인디케이터 뷰 동작
        self.indicator.startAnimating()

        // 1. 전달할 값 준비
        // 1-1. 이미지를 Base64 인코딩 처리
        let profile = self.profile.image?.pngData()?.base64EncodedString()
        // 1-2. 전달값을 parameters 타입의 객체로 정의
        let param: Parameters = [
            "account"       : self.fieldAccount.text!,
            "passwd"        : self.fieldPassword.text!,
            "name"          : self.fieldName.text!,
            "profile_image" : profile!
        ]

        // 2. API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)

        // 3. 서버 응답값 처리
        call.responseJSON { res in
            // 인디케이터 뷰 종료
            self.indicator.stopAnimating()

            // 3-1. JSON 형식을 값이 제대로 전달되었는지 확인
            guard let jsonObject = try! res.result.get() as? [String:Any] else {
                self.isCalling = false
                self.alert("서버 호출 과정에서 오류가 발생하였습니다.")
                return
            }

            // 3-2. 응답코드 확인
            let statusCode = jsonObject["result_code"] as! Int
            if statusCode == 0 {
                self.alert("가입이 완료되었습니다.") {
                    self.performSegue(withIdentifier: "backProfileVC", sender: self)
                }
            } else {
                self.isCalling = false
                let errorMsg = jsonObject["error_msg"] as! String
                self.alert("오류발생 : \(errorMsg)")
            }
        }
        self.isCalling = false
    }

    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!

    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)

        // 인디케이터 뷰 생성
        self.indicator = UIActivityIndicatorView()
        self.indicator.hidesWhenStopped = true
        self.view.addSubview(self.indicator)

        self.indicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
    }

    @objc func tappedProfile(_ sender: Any) {
        // 원하는 소스 타입을 선택할 수 있는 액션 시트 구현
        let msg = "프로필 이미지를 읽어올 곳을 선택하세요."
        let sheet = UIAlertController(title: msg, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { _ in
            selectLibrary(src: .savedPhotosAlbum)   // 저장되어 있는 이미지 선택
        })
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { _ in
            selectLibrary(src: .photoLibrary)       // 포토 라이브러리에서 이미지 선택
        })
        sheet.addAction(UIAlertAction(title: "카메라", style: .default) { _ in
            selectLibrary(src: .camera)             // 카메라로 촬영 후 선택
        })
        present(sheet, animated: true)

        func selectLibrary(src: UIImagePickerController.SourceType) {
            if UIImagePickerController.isSourceTypeAvailable(src) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true

                self.present(picker, animated: true)
            } else {
                self.alert("사용할 수 없는 타입입니다.")
            }
        }
    }



}

extension JoinVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")

        // 각 테이블 뷰 셀 내 텍스트 필드에 공통으로 적용될 프레임 객체
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        switch indexPath.row {
        case 0:
            self.fieldAccount = UITextField(frame: tfFrame)
            self.fieldAccount.placeholder = "계정/이메일"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)

        case 1:
            self.fieldPassword = UITextField(frame: tfFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)

        case 2:
            self.fieldName = UITextField(frame: tfFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default:
            ()
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }


}

extension JoinVC: UITableViewDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let rawval = UIImagePickerController.InfoKey.originalImage.rawValue
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawval)] as? UIImage {
            self.profile.image = img
        }
        self.dismiss(animated: true)
    }

}

extension JoinVC: UINavigationControllerDelegate {

}

extension JoinVC: UIImagePickerControllerDelegate {
}
