//
//  signUpVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/27.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class signUpVC: ViewController {
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var tfAccount: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRePassword: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var lbName: UILabel!
    var users = [Users]()
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        if users.count == 0 {
            db.collection("users").addSnapshotListener { (querySnapshot, error) in
                for snapshot in querySnapshot!.documents {
                    self.users.append(Users(dic: snapshot.data()))
                }
            }
            print("usersCount",self.users.count)
        }
    }
    @IBAction func btConfirm(_ sender: Any) {
        lbName.text = ""
        lbAccount.text = ""
        lbPassword.text = ""
        let account = tfAccount.text ?? ""
        let password = tfPassword.text ?? ""
        let rePassword = tfRePassword.text ?? ""
        let name = tfName.text ?? ""
        if account != "" {
            let check = users.filter { (user) -> Bool in
                account.elementsEqual(user.account!)
            }
            if check.count > 0{
                lbAccount.text = "已有重複帳號"
                return
            }
        } else {
            lbAccount.text = "帳號未填"
        }
        if password != "" && rePassword != ""  {
            if password == rePassword {
                if name != ""{
                    
                    Auth.auth().createUser(withEmail: account, password: password) { (authDataResult, error) in
                        print(error?.localizedDescription)
                        if error == nil {
                            let user = Users(account: account, birthDay: "", gender: "", id: "", imagePath: "", name: name, password: password, phone: "", status: "0", verificationCode: "", verificationId: "")
                            let data : [String:Any] = ["account":user.account!,"birthDay":user.birthDay!,"gender":user.gender!,"id":self.db.collection("users").document().documentID,"imagePath":user.imagePath!,"name":user.name!,"password":user.password,"phone":user.phone!,"status":user.status!,"verficationCode":user.verificationCode,"verificationId":user.verificationId]
                            self.db.collection("users").addDocument(data: data) { (error) in
                                if error == nil {
                                    self.performSegue(withIdentifier: "signUpToSignIn", sender: self)
                                }
                            }
                        }
                    }
                } else {
                    lbName.text = "名字未填"
                }
            } else {
                lbPassword.text = "密碼兩次輸入不一致"
                return
            }
        } else {
            lbPassword.text = "密碼或密碼確認未填"
        }
        
        
        
//        performSegue(withIdentifier: "signUpToSignIn", sender: self)
    }
    
    @IBAction func btCancel(_ sender: UIButton) {
       performSegue(withIdentifier: "signUpToSignIn", sender: self)
    }
    
    
   
}
