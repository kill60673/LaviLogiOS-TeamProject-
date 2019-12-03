//
//  forgotPWVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/1.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class forgotPWVC: UIViewController {
    let db = Firestore.firestore()
    var user :Users?
    @IBOutlet weak var tfAccount: UITextField!
    @IBOutlet weak var lbAccount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btConfirm(_ sender: Any) {
        lbAccount.text = ""
        db.collection("users").whereField("account", isEqualTo: tfAccount.text!).addSnapshotListener { (QuerySnapshot, error) in
            for snapShot in QuerySnapshot!.documents{
                self.user = Users(dic: snapShot.data())
            }
            if self.user == nil {
                self.lbAccount.text = "查無此帳號，請重新輸入"
            } else {
                let alertController = UIAlertController(title: "帳號確認完成", message: "按下確定後請至信箱收信", preferredStyle: .alert)
                let ok = UIAlertAction(title: "確定", style: .default) { (alertAction) in
                forgetPasswordWithEmail(email: self.tfAccount.text!)
                    self.dismiss(animated: true)
                }
                alertController.addAction(ok)
                self.present(alertController,animated: true)
            }
        }
        
    }
}
func forgetPasswordWithEmail(email: String){
    Auth.auth().sendPasswordReset(withEmail: email) { error in
        if let error = error {
            print(error.localizedDescription)
        } else {
            // 寄送新密碼
        }
    }
}
