//
//  admListTVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/3.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class admListTVC: UITableViewController {
    var loadingView:UIView?
    let db = Firestore.firestore()
    var adms = [Users]()
    var dicImages = [String:UIImage]()
    
    override func viewWillAppear(_ animated: Bool) {
        adms = [Users]()
        loadFireStore()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "刪除") { (action, view, bool) in
            let adm = self.adms[indexPath.row]
            let blockController = UIAlertController(title: "確認將該管理者刪除？", message: "請輸入\(adm.account!)作確認", preferredStyle: .alert)
            blockController.addTextField { (textfield) in
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
            }
            let ok = UIAlertAction(title: "確定", style: .default) { (action) in
                print([indexPath])
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//                tableView.deleteRows(at: [indexPath], with: .fade)
                print(blockController.textFields![0].text)
                if (blockController.textFields![0].text! != "" && blockController.textFields![0].text!.elementsEqual(adm.account!)){
                    self.db.collection("users").document(adm.id!).delete { (error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                } else {
                    let controller = UIAlertController(title: "輸入錯誤", message: "請重新嘗試", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "確定", style: .default) { (action) in
                    }
                    controller.addAction(ok)
                    self.present(controller,animated: true)
                }
            }
            blockController.addAction(cancel)
            blockController.addAction(ok)
            self.present(blockController,animated: true)
        }
        delete.backgroundColor = .red
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    @IBAction func btAdd(_ sender: Any) {
        let addController = UIAlertController(title: "新增管理者", message: "請輸入管理者資料", preferredStyle: .alert)
        addController.addTextField { (textfield) in
            textfield.placeholder = "請輸入新增帳號"
        }
        addController.addTextField { (textfield) in
            textfield.placeholder = "請輸入密碼"
            textfield.isSecureTextEntry = true
        }
        addController.addTextField { (textfield) in
            textfield.placeholder = "請再次輸入密碼"
            textfield.isSecureTextEntry = true
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
        }
        let ok = UIAlertAction(title: "確定", style: .default) { (action) in
            if addController.textFields![0].text! != "" && addController.textFields![1].text! != "" && addController.textFields![2].text! != "" {}else{
                let controller = UIAlertController(title: "欄位不得為空", message: nil, preferredStyle: .alert)
                let yes = UIAlertAction(title: "確定", style: .default) { (action) in
                }
                controller.addAction(yes)
                self.present(controller,animated: true)
                return
            }
            
            if addController.textFields![1].text!.elementsEqual(addController.textFields![2].text!){
                print("++++")
            } else {
                let controller = UIAlertController(title: "兩次密碼輸入不符", message: nil, preferredStyle: .alert)
                let yes = UIAlertAction(title: "確定", style: .default) { (action) in
                }
                controller.addAction(yes)
                self.present(controller,animated: true)
                return
            }
        }
        addController.addAction(cancel)
        addController.addAction(ok)
        self.present(addController,animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return adms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "admsList", for: indexPath) as! admListCell
        let adm = adms[indexPath.row]
        print(adm.account!)
        cell.lbName.text = adm.name!
        cell.lbAccount.text = adm.account!
        cell.ivPhoto.image = dicImages[adm.imagePath!]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
    
    func  loadFireStore(){
        loadingView = addLoadingView(view: view, x: 180, y: 370)
//        loadingView?.backgroundColor = .purple
        db.collection("users").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if document.data()["account"] as! String != Auth.auth().currentUser?.email {
                        if document.data()["status"] as! String == "1" {
                            self.adms.append(Users(dic: document.data()))
                        }
                    }
                }
            }
            self.tableView.reloadData()
            self.downloadImage()
        }
    }
    func downloadImage (){
        for adm in adms {
            let imagePath = adm.imagePath!
            let fileReference = Storage.storage().reference().child(imagePath)
            fileReference.getData(maxSize: .max) { (data, error) in
                if let data = data ,let image = UIImage(data: data){
                    self.dicImages[imagePath] = image
                }else{
                    self.dicImages[imagePath] = nil
                }
                self.tableView.reloadData()
                removeLoadingView(self.loadingView)
            }
        }
    }
}
