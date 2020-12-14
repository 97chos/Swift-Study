//
//  MemoDAO.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/14.
//

import Foundation
import CoreData

class MemoDAO {

    // 관리 객체 컨텍스트 반환
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    //MARK: - 저장된 메모 불러오기 메소드
    func fetch(Keyword text: String? = nil) -> [MemoData] {
        var memolist = [MemoData]()

        // 1. 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()

        // 1-1. 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]

        // 1-2. 검색 키워드가 있을 경우 검색 조건 추가
        if let t = text, !(t.isEmpty) {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }

        do {
            let resultset = try self.context.fetch(fetchRequest)

            // 2. 읽어온 결과 집합을 순회하면서 [MemoData] 타입으로 변환
            for record in resultset {
                // 3. MemoData 객체 생성
                let data = MemoData()

                // 4. MemoMO 프로퍼티 값을 MemoData의 프로퍼티로 복사
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate! as Date
                data.objectID = record.objectID

                // 4-1. 이미지가 있을 때만 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                // 5. MemoData 객체를 memolist 배열에 추가
                memolist.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
        return memolist
    }

    //MARK: - 새 메모 저장 메소드
    func insert (_ data: MemoData) {

        // 1. 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO

        // 2. MemoData로부터 값 복사
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!

        if let image = data.image {
            object.image = image.pngData()!
        }

        // 3. 영구 저장소에 변경 사항을 반영
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
    }

    //MARK: - 메모 삭제 메소드
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        // 삭제할 객체를 찾아, 컨텍스트에서 삭제
        let object = self.context.object(with: objectID)
        self.context.delete(object)

        do {
            // 삭제된 내역을 영구저장소에 반영
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
            return false
        }
    }

}
