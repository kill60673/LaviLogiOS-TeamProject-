//
//  userListVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/2.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class userListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var tv: UITableView!
    let db = Firestore.firestore()
    var arrowIsDown = true
    var justUsers = [Users]()
    var justAllUsers = [Users]()
    var justNoBlockUsers = [Users]()
    var justBlockUsers = [Users]()
    var dicImages = [String:UIImage]()
    @IBOutlet var options: [UIButton]!
    @IBOutlet weak var btMainOption: UIButton!
    @IBOutlet weak var btArrow: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirebase()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return justUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as! userListCell
        let user = justUsers[indexPath.row]
        print(user.name!)
        print(user.status!)
        print()
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
//                        print(user.account!)
//                        print(user.status!)
//                        print()
//      user.status若0是一般,為2則是封鎖
        if (cell.lbStatus.text!.elementsEqual("停權")) {
            cell.contentView.backgroundColor = UIColor.red
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if justUsers[indexPath.row].status! == "0" {
            let edit = UIContextualAction(style: .normal, title: "停權") { (action, view, bool) in
                let user = self.justUsers[indexPath.row]
                let blockController = UIAlertController(title: "將該使用者停權", message: self.justUsers[indexPath.row].account!, preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "確定停權", style: .default) { (alerAction) in
                    print(user.name!)
                    print(user.status!)
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
                    print(user.name!)
                    print(user.status!)
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
    }
    
    @IBAction func optionPressed(_ sender: UIButton) {
        for option in options {
            option.isHidden.toggle()
        }
        arrowIsDown = true
        btArrow.setImage(UIImage(systemName: "arrowtriangle.down.fill"), for: .normal)
        btMainOption.titleLabel!.text! = sender.currentTitle!
        
        if sender.tag == 2 {
            justUsers = justAllUsers
            tv.reloadData()
        }
        if sender.tag == 3 {
//            一般
            justNoBlockUsers = [Users]()
            for user in justAllUsers {
                if user.status == String(0) {
                    justNoBlockUsers.append(user)
                }
            }
            justUsers = justNoBlockUsers
//            print("A",justNoBlockUsers.count)
            
//            for user in justNoBlockUsers {
//                print(user.name!)
//                print(user.status!)
//                print()
//            }
            tv.reloadData()
        }
        if sender.tag == 4 {
//            封鎖
            justBlockUsers = [Users]()
            for user in justAllUsers {
                if user.status == String(2) {
                    justBlockUsers.append(user)
                }
            }
            justUsers = justBlockUsers
            tv.reloadData()
        }
    }
    func loadFirebase(){
        db.collection("users").addSnapshotListener { (QuerySnapshot, error) in
            for snapShot in QuerySnapshot!.documents {
                let user = Users(dic: snapShot.data())
                if !user.status!.elementsEqual("1"){
                    self.justUsers.append(user)
                }
            }
            self.tv.reloadData()
            self.downloadImage()
            self.justAllUsers = self.justUsers
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
//                print(user.account!)
//                print(user.status!)
//                print()
            }
        }
    }
}
