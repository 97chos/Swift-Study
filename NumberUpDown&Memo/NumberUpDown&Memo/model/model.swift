//
//  model.swift
//  NumberUpDown&Memo
//
//  Created by 조상호 on 2020/11/05.
//  Copyright © 2020 조상호. All rights reserved.
//

import Foundation

class memo {
    var content: String
    var date: Date
    
    init(content: String) {
        self.content = content
        date = Date()
    }

    static var dummyMemoList = [
        memo(content: "Lorem Ipsum"),
        memo(content: "test")
    ]
}
