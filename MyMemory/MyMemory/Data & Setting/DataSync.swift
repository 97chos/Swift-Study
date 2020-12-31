//
//  DataSync.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/16.
//

import UIKit
import CoreData
import Alamofire

// 서버 데이터 동기화 담당 클래스
class DataSync {

    // 코어 데이터의 컨텍스트 객체
    lazy var context: NSManagedObjectContext = {
        let appDlegate = UIApplication.shared.delegate as! AppDelegate
        return appDlegate.persistentContainer.viewContext
    }()
}

// MARK: - DataSync 유틸 메소드
extension DataSync {

    //MARK: - String -> Date
    func StringToDate(_ value: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return df.date(from: value)!
    }

    //MARK: - Date -> String
    func DateToString(_ value: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return df.string(from: value)
    }

    //MARK: - 서버에 백업한 데이터 내려받는 메소드
    func downloadBackupData() {

        // 1. 최초 1회만 다운로드 받을 수 있도록 체크
        let ud = UserDefaults.standard
        guard ud.value(forKey: "firstLogin") == nil else { return }

        // 2. API 호출용 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAutoHeader

        // 3. API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)

        // 4. 응답 처리
        call.responseJSON { res in
            // 5. 응답 결과가 잘못되었거나 list 항목이 없을 경우에는 잘못된 응답이므로 그대로 종료
            guard let jsonObject = try! res.result.get() as? NSDictionary else { return }
            guard let list = jsonObject["list"] as? NSArray else { return }

            // 6. list 항목을 순회하면서 각각의 데이터를 코어 데이터에 저장
            for item in list {
                guard let record = item as? NSDictionary else { return }

                // 7. MemoMO 타입의 관리 객체 인스턴스를 생성하고, 각 속성에 값을 대입
                let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO

                object.title = (record["title"] as! String)
                object.contents = (record["contents"] as! String)
                object.regdate = self.StringToDate(record["create_date"] as! String)
                object.sync = true

                // 8. 이미지가 있을 경우에만 대입
                if let imagePath = record["image_path"] as? String {
                    let url = URL(string: imagePath)!
                    object.image = try! Data(contentsOf: url)
                }
            }

            // 9. 영구 저장소에 커밋
            do {
                try self.context.save()
            } catch let e as NSError {
                self.context.rollback()
                NSLog("An error has occured : %s", e.localizedDescription)
            }

            // 10 .다운로드가 끝났으므로 이훙는 실행되지 않도록 처리
            ud.setValue(true, forKey: "firstLogin")
        }
    }

    //MARK: - 코어데이터 Memo 엔터티에 저장된 데이터 중 서버와 동기화 되지 않은 것을 찾아 업로드하는 메소드
    func uploadData(_ indicatorView: UIActivityIndicatorView? = nil) {

        // 1. 코어데이터 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()

        // 2. 최신 글 순으로 정렬
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]

        // 3. 업로드가 되지 않은 데이터만 추출
        fetchRequest.predicate = NSPredicate(format: "sync = false")

        do {
            let resultset = try self.context.fetch(fetchRequest)

            // 4. 읽어온 결과 집합을 순회하며 [MemoData] 타입으로 변환
            for record in resultset {
                indicatorView?.startAnimating()                 // 로딩 시작
                print("upload date == \(record.title!)")

                // 6. 서버에 업로드
                self.uploadDatum(record) {
                    if record == resultset.last {               // 마지막 데이터의 업로드가 끝났다면 로딩 인디케이터 중지
                        indicatorView?.stopAnimating()
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    //MARK: - 인자값으로 입력된 개별 MemoMO 객체를 찾아 서버에 업로드
    func uploadDatum(_ item: MemoMO, complete: (() -> Void)? = nil) {

        // 1. 헤더 설정
        let tk = TokenUtils()
        guard let header = tk.getAutoHeader else {
            print("로그인 상태가 아니므로 \(item.title!)을 업로드 할 수 없습니다.")
            return
        }

        // 2. 전송할 값 설정
        var param: Parameters = [
            "title" : item.title!,
            "contents" : item.contents!,
            "create_date" : self.DateToString(item.regdate!)
        ]

        // 2-1. 이미지가 있을 경우 이미지도 전송할 값에 포함
        if let imageData = item.image as Data? {
            param["image"] = imageData.base64EncodedString()
        }

        // 3. 전송
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/save"
        let upload = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)

        // 4. 응답 및 결과 처리

        upload.responseJSON { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                print("잘못된 응답입니다.")
                return
            }

            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                print("[\(item.title!)]이 등록되었습니다.")

                // 코어 데이터에 반영
                do {
                    item.sync = true
                    try self.context.save()
                } catch let e as NSError {
                    self.context.rollback()
                    NSLog("An error has occured : %s", e.localizedDescription)
                }
            } else {
                print(jsonObject["error_msg"] as! String)
            }

            complete?()
        }
    }
}
