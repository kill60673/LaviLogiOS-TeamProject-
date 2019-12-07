//
//  MyProfileTVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class MyProfileTVC: UITableViewController {
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbGender: UILabel!
    @IBOutlet weak var lbBirthDay: UILabel!
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var ivPhoto: UIImageView!
    var datePicker : UIDatePicker?
    var toolBar = UIToolbar()
    var db : Firestore!
    var id : String?
    var user = Users()
    var loadingView = UIActivityIndicatorView()
    var isDatePickerShow = false
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.isHidden = false
        loadingView.startAnimating()
        loadingView.frame.origin = CGPoint(x: 200, y: 400)
        tableView.addSubview(loadingView)
        if let account = userAccount {
            lbAccount.text = account
            db = Firestore.firestore()
            loadFireStore()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadPhoto()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datePicker?.removeFromSuperview()
        
        if indexPath.section == 1 && indexPath.row == 0 {
//            改名字
            let alertController = UIAlertController(title: "請輸入欲更改的名稱", message: "現在名稱：\(lbName.text!)", preferredStyle: .alert)
            alertController.addTextField { (textfield) in
            }
            let ok = UIAlertAction(title: "確定", style: .default) { (alert) in
                let name = alertController.textFields?[0].text
                if name == "" {
                 let alertC = UIAlertController(title: "輸入錯誤", message: "名稱未變更", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "確定", style: .default) { (alert) in
                    }
                    alertC.addAction(ok)
                    self.present(alertC,animated: true)
                } else {
                    let name = alertController.textFields![0].text
                    self.db.collection("users").document((self.user.id!)).setData(["account":self.user.account!,"birthDay":self.user.birthDay,"gender":self.user.gender,"id":self.user.id!,"imagePath":self.user.imagePath!,"name":name,"password":self.user.password!,"phone":self.user.phone,"status":self.user.status,"verificationCode":self.user.verificationCode,"verificationId":self.user.verificationId]) { (error) in
                        if error == nil {
                            self.alertControl(conTitle: "名稱變更完成", conMessage: nil)
                            self.lbName.text = name
                        }
                    }
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .default) { (alert) in
            }
            alertController.addAction(cancel)
            alertController.addAction(ok)
            present(alertController,animated: true)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
//            改性別
            let alertController = UIAlertController(title: "請選擇欲變更性別", message: nil, preferredStyle: .alert)
            let maleAction = UIAlertAction(title: "男", style: .default) { (alert) in
                self.genderChange(gender: "男")
            }
            let femaleAction = UIAlertAction(title: "女", style: .default) { (alert) in
                self.genderChange(gender: "女")
            }
            let othersAction = UIAlertAction(title: "其他", style: .default) { (alert) in
                self.genderChange(gender: "其他")
            }
            alertController.addAction(maleAction)
            alertController.addAction(femaleAction)
            alertController.addAction(othersAction)
            present(alertController,animated: true)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
//            改生日
            if isDatePickerShow{
                isDatePickerShow = false
                datePicker?.removeFromSuperview()
                dataChange(dateString:lbBirthDay.text!)
            }else{
                isDatePickerShow = true
                datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 500, height: 200))
                datePicker?.datePickerMode = .date
                datePicker!.date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月dd日"
                let birthDayDate = formatter.date(from: user.birthDay!)
                if birthDayDate != nil {
                 datePicker?.date = birthDayDate!
//                    新加入的會員，沒有登記過的生日資料，會是nil
                }
                datePicker?.locale = Locale(identifier: "zh_TW")
                datePickerAddToolBar()
                datePicker?.center = CGPoint(x: (UIScreen.main.bounds.width)*0.55, y: (UIScreen.main.bounds.height)*0.6)
                datePicker?.backgroundColor = UIColor.white
                
                //          datePicker?.inputAccessoryView = toolBar
                
                self.view.addSubview(datePicker!)
                datePicker?.addTarget(self, action: #selector(datePickChange), for: .valueChanged)
            }
            
        }
        if indexPath.section == 2 && indexPath.row == 2 {
            //            改手機號碼
            
        }
        if indexPath.section == 2 && indexPath.row == 3 {
//            改密碼,直接拉線到下一頁
            
        }
    }
    func alertControl (conTitle:String,conMessage:String?) {
        let alertController = UIAlertController(title: conTitle, message: conMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確定", style: .default) { (alert) in
        }
        alertController.addAction(alertAction)
        present(alertController,animated: true)
    }
    
    func dataChange(dateString:String){
        self.db.collection("users").whereField("account", isEqualTo: user.account!).getDocuments { (querySnapshot, error) in
            
            if let querySnapshot = querySnapshot {
                let document = querySnapshot.documents.first
                document?.reference.updateData(["birthDay":dateString], completion: { (error) in
                    if error == nil {
                        self.alertControl(conTitle: "生日變更完成", conMessage: nil)
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    
    func genderChange(gender:String){
       
        self.db.collection("users").whereField("account", isEqualTo: user.account!).getDocuments { (querySnapshot, error) in
            
            if let querySnapshot = querySnapshot {
                let document = querySnapshot.documents.first
                document?.reference.updateData(["gender":gender], completion: { (error) in
                    if error == nil {
                        self.alertControl(conTitle: "性別變更完成", conMessage: nil)
                        self.lbGender.text = gender
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }
    @objc func datePickChange(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM日dd月"
        lbBirthDay.text = formatter.string(from: datePicker!.date)
//        self.datePicker!.removeFromSuperview()
    }
    func datePickerAddToolBar(){
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.darkGray
        toolBar.sizeToFit()
//        datePicker?.addSubview(toolBar)
//        datePicker?.inputAccessoryView = toolBar
        let doneButton = UIBarButtonItem(title: "確認", style: .done, target: self, action: #selector(self.doneAction))
        let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeView))
        let spaceLeftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton,spaceLeftButton,spaceLeftButton,doneButton], animated: false)
       }
    @objc func doneAction() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        lbBirthDay.text = formatter.string(from: datePicker!.date)
        self.datePicker!.removeFromSuperview()
    }
    @objc func closeView() {
        self.view.endEditing(true)
    }
    func  loadFireStore(){
        db.collection("users").whereField("account", isEqualTo: userAccount!).getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    self.user = Users(dic: document.data())
                    self.lbName.text = self.user.name!
                    self.lbPhone.text = self.user.phone!
                    self.lbGender.text = self.user.gender!
                    self.lbBirthDay.text = self.user.birthDay!
                    self.id = self.user.id!
                    let password = self.user.password!
                    var text = ""
                    //                        for _ in 0..<password.count {
                    //                            text += "*"
                    //                        }
                    self.lbPassword.text = text
                }
            }
        }
    }
    
    func downloadPhoto(){
        print("看看",userAccount)
        var imagePath = ""
        let db = Firestore.firestore()
            db.collection("users").whereField("account", isEqualTo: "\(userAccount!)").addSnapshotListener { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot else {
                    return
                }
                for snapshot in querySnapshot.documents {
//                    let data = snapshot.data()["imagePath"] as! String
                    imagePath = snapshot.data()["imagePath"] as! String
    //                print("imagePath =","\(imagePath)")
                    let fileReference = Storage.storage().reference().child("\(imagePath)")
    //                print("fileReference =",fileReference)
                    fileReference.getData(maxSize: .max) { (data, error) in
                        if let data = data, let image = UIImage(data: data) {
                            self.ivPhoto.image = image
                        }else {
                            print(error?.localizedDescription)
                        }
                        self.loadingView.isHidden = true
                    }
                }
        }
    }
}
