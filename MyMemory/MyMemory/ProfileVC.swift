//
//  ProfileVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/01.
//

import Foundation
import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController {

    let profileImage = UIImageView()    // 프로필 사진 이미지
    let tv = UITableView()              // 프로필 목록
    let uInfo = UserInfoManager()       // 개인 정보 관리 매니저
    var isCalling = false               // API 호출 상태값 관리 변수
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // 토큰 인증 여부 체크
        self.tokenvalidate()

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

        // 인디케이터 뷰 맨 위로 가져오기
        self.view.bringSubviewToFront(self.indicatorView)
    }

    //MARK: - 창 닫기 메소드
    @objc func close(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }

    //MARK: - 로그인 창 표시 메소드
    @objc func doLogin(_ sender: Any) {

        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n 잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }

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
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .default){ _ in

            // 인디케이터 실행
            self.indicatorView.startAnimating()

            let account = loginAlert.textFields?[0].text ?? ""
            let passwd = loginAlert.textFields?[1].text ?? ""

            // 비동기 방식으로 적용되는 부분
            self.uInfo.login(account: account, passwd: passwd, success: {
                // 인디케이터 종료
                self.indicatorView.stopAnimating()

                self.tv.reloadData()                                // 테이블 뷰 갱신
                self.profileImage.image = self.uInfo.profile        // 이미지 프로파일 갱신
                self.drawBtn()

                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {      // 블록 내에 작성된 코드를 백그라운드에서 실행할 수 있게 해주는 글로벌 큐
                    sync.downloadBackupData()
                }
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()
                }
            }, fail: { msg in
                // 인디케이터 종료
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
            self.isCalling = false
        })
        self.present(loginAlert, animated: true)
    }
    
    //MARK: - 로그아웃 메소드
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            // 인디케이터 실행
            self.indicatorView.startAnimating()

            self.uInfo.logout() {
                // 인디케이터 종료
                self.indicatorView.stopAnimating()

                self.tv.reloadData()
                self.profileImage.image = self.uInfo.profile
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
        // 인디케이터 실행
        self.indicatorView.startAnimating()

        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

            self.uInfo.newProfile(img, success: {
                // 인디케이터 종료
                self.indicatorView.stopAnimating()
                self.profileImage.image = img
            }, fail: { msg in
                // 인디케이터 종료
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })

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

extension ProfileVC {
    // 토큰 인증 메소드
    func tokenvalidate() {
        // 0. 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()

        // 1. 키 체인에 엑세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let tk = TokenUtils()
        guard let header = tk.getAutorizationHeader() else {
            return
        }

        // 로딩 인디케이터 시작
        self.indicatorView.startAnimating()

        // 2. 액세스 토큰 유효성 검사 API인 tokenValidate API 호출
        let url = "http://swiftapi.rupypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)

        validate.responseJSON() { res in
            self.indicatorView.stopAnimating()

            let responseBody = try! res.result.get()
            print(responseBody)
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int

            // 3-1. 응답 결과가 실패일 때, 즉 토큰이 만료되었을 때
            if resultCode != 0 {
                // 로컬 인증 실행
                self.touchID()
            }
        }
    }

    // 터치 아이디 인증 메소드
    func touchID() {

        // 1. LAContext 인스턴스 생성
        let context = LAContext()

        // 2. 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics   // 인증 정책

        // 3. 로컬 인증이 사용 가능한지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 4. 터치 아이디 인증창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (success, e) in
                if success {                    // 5. 인증 성공 : 토큰 갱신 로직
                    self.refresh()
                } else {                        // 6. 인증 실패
                    print((e?.localizedDescription)!)

                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다.") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        // 경고창과 인증창이 서로 충돌하는 것을 막기위해, 큐에 들어온 작업들이 순차적으로 처리되도록 해주는 메소드
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else {                                // 7. 인증창이 실행되지 못한 경우
            print(error!.localizedDescription)
            switch (error?.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디를 등록해주세요.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드를 설정해주세요.")
            default:
                print("터치 아이디를 사용할 수 없습니다.")
            }
            OperationQueue.main.addOperation {
                self.commonLogout(true)
            }
        }
    }

    // 토큰 갱신 메소드
    func refresh() {
        self.indicatorView.startAnimating()     // 로딩 시작

        // 1. 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAutorizationHeader()

        // 2. 리프레쉬 토큰 전달 준비
        let refreshToken = tk.load("kr.co.rubypaer.MyMemory", account: "refreshToken", value: "")
        let param: Parameters = ["refresh_token": refreshToken!]

        // 3. 호출 및 응답
        let url = "http://swiftapi.rupypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        refresh.responseJSON() { res in
            self.indicatorView.stopAnimating()  // 로딩 중지
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 4. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int

            // 성공 : 엑세스 토큰이 갱신됨
            if resultCode == 0 {
                // 4-1. 키체인에 저장된 엑세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MeMemory", account: "accessToken", value: accessToken)
            } else {        // 실패 : 엑세스 토큰 없음
                self.alert("인증이 만료되었습니다. 다시 로그인해야 합니다.") {
                    OperationQueue.main.addOperation {
                        self.commonLogout(true)
                    }
                }
            }
        }
    }

    // 토큰 갱신 과정에서 발생할 실패 상황에서 사용되는 로그아웃 메소드
    func commonLogout(_ isLogin: Bool = false) {

        // 1. 저장된 기존 개인 정보 & 키 체인 데이터를 삭제하여 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()

        // 2. 프로필 화면 UI 갱신
        self.tv.reloadData()    // 테이블 뷰 갱신
        self.profileImage.image = userInfo.profile
        self.drawBtn()

        // 3. 기본 로그인 창 실행 여부
        if isLogin {
            self.doLogin(self)
        }
    }
}
