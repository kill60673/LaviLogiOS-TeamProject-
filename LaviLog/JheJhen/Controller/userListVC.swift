//
//  userListVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/2.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class userListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UISearchBarDelegate {
    @IBOutlet weak var tv: UITableView!
    let db = Firestore.firestore()
    var arrowIsDown = true
    var justUsers = [Users]()
    var justAllUsers = [Users]()
    var justNoBlockUsers = [Users]()
    var justBlockUsers = [Users]()
    var searchUsers = [Users]()
    var dicImages = [String:UIImage]()
    var isSearch = false
    var whichOption = 2
    var isEnable = true
//    確認現在是選到哪一個選項
    @IBOutlet var options: [UIButton]!
    
    @IBOutlet weak var btMainOption: UIButton!
    @IBOutlet weak var btArrow: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirebase()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers = [Users]()
        let text = searchBar.text ?? ""
        if text == "" {
            isSearch = false
        } else {
            isSearch = true
        }
        if isSearch {
            searchUsers = justAllUsers.filter({ (user) -> Bool in
                user.account!.lowercased().contains(text)
            })
            
            if whichOption == 2 {
                justUsers = justAllUsers.filter({ (user) -> Bool in
                    user.account!.lowercased().contains(text)
                })
            }
            if whichOption == 3 {
                justUsers = justNoBlockUsers.filter({ (user) -> Bool in
                    user.account!.lowercased().contains(text)
                })
                print(justBlockUsers.count)
                print(justUsers.count)
            }
            if whichOption == 4 {
                justUsers = justBlockUsers.filter({ (user) -> Bool in
                    user.account!.lowercased().contains(text)
                })
            }
        }else{
            if whichOption == 2 {
               justUsers = justAllUsers
            }
            if whichOption == 3 {
                justUsers = justNoBlockUsers
            }
            if whichOption == 4 {
                justUsers = justBlockUsers
            }
        }
        tv.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return justUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as! userListCell
        var user = Users()
        user = justUsers[indexPath.row]
        cell.lbAccount.text = user.account!
        cell.lbName.text = user.name!
        cell.ivPhoto.image = dicImages[user.imagePath!]
        switch user.status! {
        case "0":
            cell.lbStatus.text = "一般"
        case "2":
            cell.lbStatus.text = "停權"
        default:
            cell.lbStatus.text = "異常"
        }

//      user.status若0是一般,為2則是封鎖
        if (cell.lbStatus.text!.elementsEqual("停權")) {
            cell.contentView.backgroundColor = UIColor.red
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //            因為取得資料的地方使用監聽器的方式，只要firebase資料更改，這邊就會調整，導致每次做停權及復權後，所以的users群組都會重複疊加
        //            必須在使用停復權的地方先清空一次所有群組
        if justUsers[indexPath.row].status! == "0" {
            let edit = UIContextualAction(style: .normal, title: "停權") { (action, view, bool) in
                let user = self.justUsers[indexPath.row]
                let blockController = UIAlertController(title: "將該使用者停權", message: self.justUsers[indexPath.row].account!, preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "確定停權", style: .default) { (alerAction) in
                    self.justNoBlockUsers = [Users]()
                    self.justBlockUsers = [Users]()
                    self.justAllUsers = [Users]()
                    self.justUsers = [Users]()
                    print("新的看",self.justUsers.count)
                    
                    self.db.collection("users").whereField("account", isEqualTo: user.account!).getDocuments { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot{
                            let document = querySnapshot.documents.first
                            document?.reference.updateData(["status" : "2"], completion: { (error) in
                                if error == nil {
                                    print("一般的封鎖前",self.justNoBlockUsers.count)
                                self.justNoBlockUsers = self.justNoBlockUsers.filter({ (NoBlockUser) -> Bool in
                                    !NoBlockUser.account!.elementsEqual(user.account!)
                                })
                                    print("一般的封鎖後",self.justNoBlockUsers.count)
                                    print("封鎖的添加前",self.justBlockUsers.count)
                                self.justBlockUsers.append(user)
                                    print("封鎖的添加後",self.justBlockUsers.count)
                                    print("解鎖後",self.justUsers.count)
                                self.tv.reloadData()
                                }else{
                                    print(error?.localizedDescription)
                                }
                            })
                        }
                    }
                }
                blockController.addAction(cancel)
                blockController.addAction(ok)
                self.present(blockController, animated: true, completion: nil)
            }
            edit.backgroundColor = .red // 改變背景色
            let swipeAction = UISwipeActionsConfiguration(actions: [edit])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        } else {
            let recover = UIContextualAction(style: .normal, title: "復權") { (action, view, bool) in
                let user = self.justUsers[indexPath.row]
                let recoverController = UIAlertController(title: "將該被封鎖的使用者復權", message: user.account!, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "確定復權", style: .default) { (alerAction) in
                    self.justNoBlockUsers = [Users]()
                    self.justBlockUsers = [Users]()
                    self.justAllUsers = [Users]()
                    self.justUsers = [Users]()
                    
                    let id = user.id!
                    self.db.collection("users").document(id).updateData(["status": "0"]) { (error) in
                        if error == nil {
                            print("封鎖的解封前",self.justBlockUsers.count)
                            self.justBlockUsers = self.justBlockUsers.filter({ (blockUser) -> Bool in
                                !blockUser.account!.elementsEqual(user.account!)
                            })
                            print("封鎖的解封後",self.justBlockUsers.count)
                            print("沒封鎖的",self.justNoBlockUsers.count)
                            self.justNoBlockUsers.append(user)
                            print("沒封鎖的添加後",self.justNoBlockUsers.count)
                            print("解鎖後",self.justUsers.count)
                            self.tv.reloadData()
                        }else{
                            print(error?.localizedDescription)
                        }
                    }
                }
                recoverController.addAction(cancel)
                recoverController.addAction(ok)
                self.present(recoverController, animated: true, completion: nil)
            }
            recover.backgroundColor = .lightGray // 改變背景色
            let swipeAction = UISwipeActionsConfiguration(actions: [recover])
            swipeAction.performsFirstActionWithFullSwipe = false
            return swipeAction
        }
    }
    
    @IBAction func starSelect(_ sender: UIButton) {
        for option in options {
            UIView.animate(withDuration: 0.1) {
                option.isHidden.toggle()
                self.view.layoutIfNeeded()
//                主要view(點擊的button)會直接佈置,不會隨其他view配合移動
//           選項掉下來時,會固定點選button的view,不會有一次掉下來的感覺
            }
        }
            if arrowIsDown {
                btArrow.setImage(UIImage(systemName: "arrowtriangle.up.fill"), for: .normal)
                arrowIsDown = false
            } else {
                btArrow.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
                arrowIsDown = true
            }
//        調整第一個全部使用者的按鈕，可不可以點選
        if isEnable {
            sender.setTitleColor(.black, for: .normal)
            isEnable = false
            sender.isEnabled = false
            btArrow.isEnabled = false
        }else{
            sender.setTitleColor(.black, for: .normal)
            isEnable = true
            sender.isEnabled = true
            btArrow.isEnabled = true
        }
    }
    
    @IBAction func optionPressed(_ sender: UIButton) {
        for option in options {
            option.isHidden.toggle()
        }
        arrowIsDown = true
        btArrow.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        isEnable = true
        btMainOption.isEnabled = true
        btArrow.isEnabled = true
        btMainOption.setTitleColor(.blue, for: .normal)
//        一直嘗試失敗,會一直跳回原本的title
//        btMainOption.titleLabel.text = sender.currentTitle
        btMainOption.setTitle(sender.currentTitle!, for: .normal)
//        btMainOption.titleLabel?.text = sender.currentTitle!
//        print(self.btMainOption.titleLabel!.text!)
        //        按下三個選項其中一個後，原本的主選按鈕才可以再次使用
        if sender.tag == 2 {
            whichOption = 2
            if isSearch{
                justUsers = searchUsers
            }else{
                justUsers = justAllUsers
            }
        }
        if sender.tag == 3 {
            //            一般
            whichOption = 3
//            justNoBlockUsers = [Users]()
            if isSearch{
                print(searchUsers)
                justUsers = searchUsers.filter({ (user) -> Bool in
                    user.status!.elementsEqual("0")
                })
                print(justUsers.count)
            }else{
                justUsers = justNoBlockUsers
            }
        }
        if sender.tag == 4 {
            //            封鎖
            whichOption = 4
//            justBlockUsers = [Users]()
            if isSearch{
                justUsers = searchUsers.filter({ (user) -> Bool in
                    user.status!.elementsEqual("2")
                })
            }else{
                justUsers = justBlockUsers
            }
        }
        tv.reloadData()
    }
    func loadFirebase(){
        justNoBlockUsers = [Users]()
        justBlockUsers = [Users]()
        justUsers = [Users]()
        justAllUsers = [Users]()
        print("-All",self.justAllUsers.count)
        print("-Block",self.justBlockUsers.count)
        print("-NoBlock",self.justNoBlockUsers.count)
        print("-Just",self.justUsers.count)
        db.collection("users").addSnapshotListener { (QuerySnapshot, error) in
//            因為使用監聽器的方式，只要firebase資料更改，這邊就會調整，導致每次做停權及復權後，所以的users群組都會重複疊加
//            必須在使用停復權的地方先清空一次所有群組
            for snapShot in QuerySnapshot!.documents {
                let user = Users(dic: snapShot.data())
                if !user.status!.elementsEqual("1"){
                    self.justAllUsers.append(user)
                }
                
                if user.status!.elementsEqual("2"){
                    self.justBlockUsers.append(user)
                }
                if user.status!.elementsEqual("0"){
                    self.justNoBlockUsers.append(user)
                }
            }
            self.justUsers = self.justAllUsers
            self.downloadImage()
            self.tv.reloadData()
            print("All",self.justAllUsers.count)
            print("Block",self.justBlockUsers.count)
            print("NoBlock",self.justNoBlockUsers.count)
            print("Just",self.justUsers.count)
        }
    }
    func downloadImage(){
        for user in justUsers {
            let imagePath = user.imagePath!
            let fileReference = Storage.storage().reference().child(imagePath)
            let data = fileReference.getData(maxSize: .max) { (data, error) in
                if let data = data , let image = UIImage(data: data) {
                    self.dicImages[imagePath] = image
                }
                self.tv.reloadData()
            }
        }
    }
}
