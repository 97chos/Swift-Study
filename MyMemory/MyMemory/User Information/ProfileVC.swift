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

    let indicator = UIActivityIndicatorView(style: .large)

    // API 호출 상태값을 관리할 변수
    var isCalling = false

    // 이전 화면 복귀용 메소드
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        // 새 계정 입력 화면에서 프로필 화면으로 되돌아오기 위한 표지만 역할만 할 뿐이므로 아무런 내용도 작성하지 않음
    }

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

        // 인디케이터 설정
        self.indicator.tintColor = .darkGray
        self.indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)

        // 키 체인 저장 여부 확인을 위한 코드
        let tk = TokenUtils()
        if let accessToken = tk.load("kr.co.rubypaper.MyMemory", account: "accessToken") {
            print("accessToken = \(accessToken)")
        } else {
            print("aeccesstoken is nil")
        }
        if let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken") {
            print("refreshToken = \(refreshToken)")
        } else {
            print("refreshtoken is nil")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // 토큰 인증 여부 체크
        self.tokenValidate()
    }

    //MARK: - 창 닫기 메소드
    @objc func close(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true)
    }

    //MARK: - 로그인 창 표시 메소드
    @objc func doLogin(_ sender: Any) {

        // API 중복 요청 방직 처리
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려주세요.")
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
            self.indicator.startAnimating()

            let account = loginAlert.textFields?[0].text ?? ""
            let passwd = loginAlert.textFields?[1].text ?? ""

            self.uInfo.login(account: account, passwd: passwd, success: {
                // 인디케이터 종료
                self.indicator.stopAnimating()
                self.isCalling = false

                self.tv.reloadData()                                    // 테이블 뷰 갱신
                self.profileImage.image = self.uInfo.profile            // 추가 이미지 프로필 갱신
                self.drawBtn()

                // 서버와 데이터 동기화
                let sync = DataSync()
                // 포그라운드 작업을 방해하지 않도록 백그라운드큐에서 실행하는 큐
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData()                           // 서버에 저장된 데이터가 있으면 내려받는다.
                }
                // 다운로드와 업로드가 동시에 진행
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()                                   // 서버에 저장해야 할 데이터가 있으면 업로드한다.
                }
            }, fail: { msg in
                self.indicator.stopAnimating()
                self.isCalling = false

                self.alert(msg)
            })
        })
        self.present(loginAlert, animated: true)
    }

    //MARK: - 로그아웃 메소드
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in

            self.indicator.startAnimating()

            self.uInfo.logout() {
                // Logout API 호출 및 logout() 메소드 실행이 모두 끝나면 로딩뷰 종료
                self.indicator.stopAnimating()

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

        self.indicator.startAnimating()

        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uInfo.newProfile(img, success: {
                self.indicator.stopAnimating()
                DispatchQueue.main.async {
                    self.profileImage.image = img
                }
            }, fail: { msg in
                self.indicator.stopAnimating()
                self.alert(msg)
            })
        }
        picker.dismiss(animated: true)
    }
}

extension ProfileVC: UINavigationControllerDelegate {

}


extension ProfileVC {

    //MARK: - 토큰 인증 메소드
    func tokenValidate() {
        // 0. 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()

        // 1. 키 체인에 엑세스 토큰이 없을 경우 유효성 검증을 진행하지 않음 (로그인이 안 되어있는 경우)
        let tk = TokenUtils()
        guard let header = tk.getAutoHeader else {
            return
        }

        // 로딩 인디케이터 시작
        self.indicator.startAnimating()

        // 2. tokenValidate API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)

        validate.responseJSON() { res in
            self.indicator.stopAnimating()

            let responseBody = try! res.result.get()
            print(responseBody)
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 {        // 응답 결과가 실패일 경우
                self.touchID()
            }
        }
    }

    //MARK: - 터치 아이디 인증 메소드
    func touchID() {
        // 1. LAContext 인스턴스 생성
        let context = LAContext()

        // 2. 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics   // 인증 정책

        // 3. 로컬인증서 사용이 가능한지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 4. 터치 아이디 인증창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg, reply: { success, e in
                if success {                        // 인증 성공 : 토큰 갱신 로직
                    // 5-1. 토큰 갱신 로직 실행
                    self.refresh()
                } else {                            // 인증 실패
                    print((e?.localizedDescription)!)

                    switch e!._code {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다."){
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:                 // 사용자가 로컬 인증 대신 암호를 선택한 경우, 인증창과 경고창이 서로 충돌할 수 있기에 operationqueue를 사용하여 순차적으로 처리
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            })
        } else {    // 인증창이 실행되지 않은 내용에 대한 경우
            // 인증 실행 불가 원인에 따른 대응 로직 실행
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default:        // LAError.touchIDNotAvailable 포함
                print("터치 아이디를 사용할 수 없습니다.")
            }
            OperationQueue.main.addOperation {
                self.commonLogout(true)
            }
        }
    }

    //MARK: - 토큰 갱신 메소드
    func refresh() {
        self.indicator.startAnimating()

        // 1. 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAutoHeader

        // 2. 리프레시 토큰 전달 준비
        let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token" : refreshToken!]

        // 3. 호출 및 응답
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)

        refresh.responseJSON { res in
            self.indicator.startAnimating()

            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }

            // 4. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {                // 성공 : 액세스 토큰이 갱신됨
                // 4-1. 키 체인에 저장된 액세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
            } else {                            // 실패 : 액세스 토큰 만료
                self.alert("인증이 만료되었습니다.\n다시 로그인해주세요.")
                // 4-2. 로그아웃 처리
                OperationQueue.main.addOperation {
                    self.commonLogout(true)
                }
            }
        }
    }

    //MARK: - 토큰 갱신 실패 과정을 포함한 각종 오류 상황에서 사용될 로그아웃 메소드
    func commonLogout(_ isLogin: Bool = false) {
        // 1. 저장된 기존 개인 정보 & 키 체인 데이터를 삭제하여 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()

        // 2. 현재의 화면이 프로필 화면이라면 UI 갱신
        self.tv.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawBtn()

        // 3. 기본 로그인 창 실행 여부
        if isLogin {
            self.doLogin(self)
        }
    }
}
