//
//  changePasswordVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/1.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class changePasswordVC: UIViewController {
    @IBOutlet weak var tfRecentPW: UITextField!
    @IBOutlet weak var tfNewPW: UITextField!
    @IBOutlet weak var tfReNewPW: UITextField!
    @IBOutlet weak var lbNewPW: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var lbRecentPW: UILabel!
    let db = Firestore.firestore()
    var user : Users!
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("users").whereField("account", isEqualTo: Auth.auth().currentUser!.email!).addSnapshotListener { (querySnapshot, error) in
            for snapShot in querySnapshot!.documents {
                self.user = Users(dic: snapShot.data())
            }
        }
    }
    @IBAction func btConfirm(_ sender: Any) {
        lbNewPW.text = ""
        lbRecentPW.text = ""
        print(user.password!)
        if (tfRecentPW.text?.elementsEqual(user.password!))!{
            if tfNewPW.text != tfReNewPW.text {
                lbNewPW.text = "新密碼兩次輸入不一緻"
                return
            }
            
            Auth.auth().signIn(withEmail: user.account!, password: user.password!) { (AuthDataResult, error) in
                print("AA")
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if error == nil {
                        Auth.auth().createUser(withEmail: self.user.account!, password: self.tfNewPW.text!) { (AuthDataResult, error) in
                            print("創造",error?.localizedDescription)
                            self.user.password = self.tfNewPW.text!
                            let data : [String:Any] = ["account":self.user.account!,"birthDay":self.user.birthDay!,"gender":self.user.gender!,"id":self.user.id!,"imagePath":self.user.imagePath!,"name":self.user.name!,"password":self.user.password,"phone":self.user.phone!,"status":self.user.status!,"verficationCode":self.user.verificationCode,"verificationId":self.user.verificationId]
                            self.db.collection("users").document(self.user.id!).setData(data) { (error) in
                                print("BB")
                                if error == nil {
                                    print("更新成功")
                                    self.performSegue(withIdentifier: "changePWToMyProfile", sender: self)
                                }else{
                                    print("更新失敗")
                                }
                            }
                            
                        }
                    } else {
                        print("A",error!.localizedDescription)
                    }
                })
            }
        } else {
            lbRecentPW.text = "舊密碼輸入錯誤"
        }
    }
}
