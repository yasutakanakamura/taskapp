//
//  Task.swift
//  taskapp
//
//  Created by 中村 泰貴 on 2018/03/10.
//  Copyright © 2018年 yasutaka.nakamura. All rights reserved.
//

import RealmSwift

class Task: Object {
    //監理用の ID プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    /*
     id をプライマリーキーとして設定
    */
    override static func primaryKey() -> String? {
        return "id"
    }
}
