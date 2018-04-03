//
//  ViewController.swift
//  taskapp
//
//  Created by 中村 泰貴 on 2018/02/26.
//  Copyright © 2018年 yasutaka.nakamura. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var serchBarText: UISearchBar!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    let serchText :String = ""
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート:降順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        serchBarText.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //テキストが変更されるたびに呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let serchText :String! = serchBarText.text
        print(serchText)
        //
        if serchText != "" {
            taskArray = try! Realm().objects(Task.self).filter("category == %@", serchText).sorted(byKeyPath: "date", ascending: false)
            tableView.reloadData()
        } else {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
            tableView.reloadData()
        }
    }
    
    //Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let serchText :String! = serchBarText.text
        print(serchText)
        //
        if serchText != "" {
            taskArray = try! Realm().objects(Task.self).filter("category == %@", serchText).sorted(byKeyPath: "date", ascending: false)
            tableView.reloadData()
        } else {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
            tableView.reloadData()
        }
    }
    
    //MARK: UITableViewDataSourceプロトコルのメソッド
    //データの数(=セルの数)を返すメソッド(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
    }
    
    //各セルの内容を返すメソッド(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)  -> UITableViewCell {
        //再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    //MARK: UITalbeViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //削除されたタスクを取得する
            let task = taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //segue で画面遷移する時に呼ばれる
    override func prepare(for segue:UIStoryboardSegue, sender:Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController //←.destinataionは？　このas!は何？
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}


