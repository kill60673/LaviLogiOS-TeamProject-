//
//  SearchFriendVC.swift
//  LaviLog
//
//  Created by 田乙男 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class SearchFriendVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var images = [String: UIImage]()
    var friends = [Friend]()
    
    var searchFriends = [Friend]() // 儲存搜尋結果資料
    var search = false // 是否要顯示搜尋後資料
    
    func getFriends() {
        var imagePaths = [String]()
        let db = Firestore.firestore() // 建立儲藏庫實體
        db.collection("friends").addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            self.friends = querySnapshot.documents.map {
                Friend(dic: $0.data())
            }
            
            self.tableView.reloadData()
            
            for snapshot in querySnapshot.documents {
                imagePaths.append(snapshot.data()["imagePath"] as! String)
                print("path",imagePaths)
                
                for imagePath in imagePaths {
                    let fileReference = Storage.storage().reference().child("\(imagePath)")
                    print("filepath",fileReference)
                    fileReference.getData(maxSize: .max) { (data, error) in
                        if let data = data, let image = UIImage(data: data) {
                            self.images[imagePath] = image
                            print("imagePath",imagePath)
                            print("self.images",self.images)
                        }else {
                            print(error?.localizedDescription)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFriends()
    }
    
    // 點擊鍵盤上的Search按鈕時將鍵盤隱藏
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        // 如果搜尋條件為空字串，就顯示原始資料；否則就顯示搜尋後結果
        if text == "" {
            search = false
        } else {
            // 搜尋原始資料內有無包含關鍵字(不區別大小寫)
            searchFriends = friends.filter({ (friend) -> Bool in
                return friend.name!.uppercased().contains(text.uppercased())
            })
            search = true
        }
        tableView.reloadData()
    }
    
}

extension SearchFriendVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search {
            return searchFriends.count
        } else {
            return friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var friend:Friend?
        
        if search {
            friend = searchFriends[indexPath.row]
        } else {
            friend = friends[indexPath.row]
        }
        let cellId = "friendCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! FriendCell
        
        let image = images[friend!.imagePath!]
        cell.ivFriend.image = image
        cell.lbFriend.text = friend?.name
        print(friend!.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Identifier必須設定與Indentity inspector的Storyboard ID相同 */
        let searchFriendResultVC = self.storyboard?.instantiateViewController(withIdentifier: "searchFriendResultVC") as! SearchFriendResultVC
        let friend = friends[indexPath.row]
        searchFriendResultVC.friend = friend
        searchFriendResultVC.images = images
        self.navigationController?.pushViewController(searchFriendResultVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    /* 設定可否編輯資料列 */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        //         if indexPath.row == 1{
        //             return false
        //         }
        //         //使第二個資料無法修改
        
        return true
    }
    
    /* 修改確定後，判斷編輯模式並作出回應 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 按下Delete按鈕
        if editingStyle == .delete {
            friends.remove(at: indexPath.row)
            /* 提供array，儲存著欲刪除資料的indexPath。如果只刪除一筆資料，array內存放一個indexPath元素即可 */
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
}
