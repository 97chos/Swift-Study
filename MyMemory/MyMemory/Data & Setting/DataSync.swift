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

    // String -> Date
    func StringToDate(_ value: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return df.date(from: value)!
    }

    // Date -> String
    func DateToString(_ value: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return df.string(from: value)
    }

    // 서버에 백업한 데이터 내려받는 메소드
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
}
