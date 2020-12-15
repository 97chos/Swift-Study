//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/03.
//

import Foundation
import UIKit
import Alamofire

struct UserInfoKey {
    // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

// 계정 및 사용자 정보를 저장 관리하는 클래스
class UserInfoManager {
    
    // 연산 프로퍼티 loginId 정의
    var logInId: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }

    var account: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }

    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }

    var profile: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg")
            }
        }
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }

    var isLogin: Bool {
        // 로그인 아이디가 0이거나 계정이 비어있다면
        if self.logInId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }

    // 로그인 처리 메소드
    func login(account: String, passwd: String, success: (()->Void)? = nil, fail: ((String) -> Void)? = nil) {

        // 1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account" : account,
            "passwd"  : passwd
        ]

        // 2. API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)

        // 3. API 호출 결과 정리
        call.responseJSON() { res in
            // 3-1. JSON 형식으로 응답했는지 확인
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("잘못된 응답 형식입니다:\(result)")
                return
            }

            // 3-2. 응답 코드 확인. 0이면 성공
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {        // 로그인 성공
                // 3-3. 로그인 성공 처리 로직
                let user = jsonObject["user_info"] as! NSDictionary

                self.logInId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String

                // 3-4. user_info 항목 중에서 프로필 이미지 처리
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }

                // 토큰 정보 추출
                let accessToken = jsonObject["access_token"] as! String     // 액세스 토큰 추출
                let refreshToken = jsonObject["refresh_token"] as! String   // 리프레쉬 토큰 추출

                // 토큰 정보 저장
                let tk = TokenUtils()
                tk.save("kr.co.rubypaper.Mymemory", account: "accessToken", value: accessToken)
                tk.save("kr.co.rubypaper.Mymemory", account: "refreshToken", value: refreshToken)
                

                // 3-5. 인자값으로 입력된 success 클로저 블록 실행
                success?()
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인에 실패했습니다."
                fail?(msg)
            }
        }
    }

    // 로그아웃 처리 메소드
    func logout() -> Bool {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        return true
    }
}
