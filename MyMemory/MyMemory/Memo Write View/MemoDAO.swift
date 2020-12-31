//
//  MemoDAO.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/14.
//

import Foundation
import CoreData

class MemoDAO {

    // 객체 관리 컨텍스트
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    // 전체 데이터 불러오는 메소드
    func fetch(keyword text: String? = nil) -> [MemoData] {

        var memolist = [MemoData]()

        // 1. 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()

        // 1-1. 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdate = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdate]

        // 1-2 검색 키워드가 있을 경우 검색 조건 추가
        if let t = text, !(t.isEmpty) {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }

        do {
            let resultSet = try self.context.fetch(fetchRequest)

            // 2. 읽어온 결과 집합을 순회하면서 [MemoData] 타입으로 변환
            for record in resultSet {
                // 3. MemoData 객체를 생성
                let data = MemoData()

                // 4. MemoMO 프로퍼티 값을 MemoData 객체의 프로퍼티로 복사
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate
                data.objectID = record.objectID

                if let image = record.image {
                    data.image = UIImage(data: image)
                }

                memolist.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }

        return memolist
    }

    // 데이터 저장 메소드
    func insert(_ data: MemoData) {

        // 1. 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: context) as! MemoMO

        // 2. MemoData로부터 값 복사
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate

        if let image = data.image {
            object.image = image.pngData()
        }

        // 3. 영구 저장소에 해당 데이터 커밋
        do {
            try self.context.save()

            // 로그인되어 있을 경우 서버에 업로드
            let tk = TokenUtils()

            if tk.getAutoHeader != nil {
                // 백그라운드에서 처리
                DispatchQueue.global(qos: .background).async {
                    // 서버에 데이터를 업로드
                    let sync = DataSync()
                    sync.uploadDatum(object)
                }
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
    }

    // 데이터 삭제 메소드
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let object = context.object(with: objectID)

        context.delete(object)

        do {
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occured : %s ", e.localizedDescription)
            return false
        }
    }

}
