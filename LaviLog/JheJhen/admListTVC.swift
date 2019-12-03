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
    let db = Firestore.firestore()
    var adms = [Users]()
    var dicImages = [String:UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFireStore()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "admsList", for: indexPath) as! userListCell
        let adm = adms[indexPath.row]
        print(adm.account!)
        cell.lbName.text = adm.name!
        cell.lbAccount.text = adm.name!
        cell.ivPhoto.image = dicImages[adm.imagePath!]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func  loadFireStore(){
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
            }
        }
    }
}
