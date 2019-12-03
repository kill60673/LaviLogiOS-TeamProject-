//
//  signInVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import FirebaseAuth

class signInVC: UIViewController {

    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    var loginHandle:AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        loginHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                print("auth",auth)
                print("\(user.email!)登入")
                self.performSegue(withIdentifier: "signInToMain", sender: self)
            }else {
                print("未登入")
            }
        })
        
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.email!)
            print("帳號已登入")
            performSegue(withIdentifier: "signInToMain", sender: self)
        }else {
            print("帳號未登入")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let loginHandle = loginHandle {
            Auth.auth().removeStateDidChangeListener(loginHandle)
            self.loginHandle = nil
        }
    }
    @IBAction func btSignIn(_ sender: Any) {
        let account = tfName.text ?? ""
        let password = tfPassword.text ?? ""
        if account != "" && password != "" {
            Auth.auth().signIn(withEmail: account, password: password) { (result, error) in
                guard error == nil else{
                    if (error?.localizedDescription.contains("no user record"))!{
                        self.lbPassword.text = "該帳號並未註冊"
                        return
                    }else if (error?.localizedDescription.contains("password is invalid"))! {
                        self.lbPassword.text = "密碼輸入錯誤"
                        return
                    }
                    print(error!.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "signInToMain", sender: self)
            }
        }else {
            lbPassword.text = "帳號密碼未輸入，請再確認"
        }
    }
    @IBAction func btPassword(_ sender: Any) {
    }
    
    @IBAction func DidEndOnExit(_ sender: Any) {
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        tfName.resignFirstResponder()
        tfPassword.resignFirstResponder()
    }
}
