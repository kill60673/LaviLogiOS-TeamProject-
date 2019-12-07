//
//  signUpPhoneVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class signUpPhoneVC: UIViewController {

    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var tfPhone: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func btConfirm(_ sender: Any) {
        let phone = tfPhone.text ?? ""
        if phone != "" {
            Auth.auth().languageCode = "zh-TW"
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
            }
        } else {
            lbPhone.text = "電話號碼輸入錯誤"
        }
    }
}
