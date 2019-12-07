//
//  signInVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import GoogleSignIn

class signInVC: UIViewController,GIDSignInDelegate {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    var loginHandle:AuthStateDidChangeListenerHandle?
    let db = Firestore.firestore()
    var manager : LoginManager?
    override func viewDidLoad() {
        super.viewDidLoad()
//        let loginButton = FBLoginButton(permissions: [ .email,.publicProfile ])
//        loginButton.frame.origin.y = 650
//        loginButton.center.x = view.center.x
//        view.addSubview(loginButton)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        loginHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
//            firebase跟facebook登入firebase的帳號都算是auth，但facebook的沒有currentUser內容
            if let user = user {
                
                self.db.collection("users").whereField("account", isEqualTo: user.email!).getDocuments { (querySnapshot, error) in
                    let snapShotFirst = querySnapshot?.documents.first
                    let user = Users(dic: (snapShotFirst?.data())!)
                    if user.status == "0" {
                        self.performSegue(withIdentifier: "signInToMain", sender: self)
                    } else if user.status == "1" {
                        self.performSegue(withIdentifier: "signInToBackStage", sender: self)
                    } else {
                        let controller = UIAlertController(title: "此帳號已被停權", message: "請聯絡客服", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "確定", style: .default) { (action) in
                        }
                        controller.addAction(ok)
                        self.present(controller,animated: true)
                    }
                }
            }else {
                print("未登入")
            }
        })
        if AccessToken.current != nil {
            print("FB帳號已登入")
            firebaseWorks.signInFireBaseWithFB { (result) in
                print("看看result",result)
                if result == Result.fail_changePW {
                    print("!QA")
                    let controller = UIAlertController(title: "已更換過密碼，請重新登入", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "確定", style: .default) { (alertAction) in
                        self.dismiss(animated: true)
                    }
                    controller.addAction(ok)
                    self.present(controller,animated:true)
                }
            }
            //            let fbAccessToken = AccessToken.current
//            guard let fbAccessTokenString = fbAccessToken?.tokenString else { return }
//            let fbCredentials = FacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
//            firebaseWorks.firebaseSignInWithCredential(credential: fbCredentials) { (result) in
//                print(result)
//            }
        }
        if Auth.auth().currentUser?.email != nil {
            userAccount = Auth.auth().currentUser!.email!
            print("firebase帳號已登入")
//            performSegue(withIdentifier: "signInToMain", sender: self)
        }else {
            print("firebase帳號未登入")
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
        if manager != nil {
            manager = nil
        }
        let account = tfName.text ?? ""
        let password = tfPassword.text ?? ""
        if account != "" && password != "" {
            let loadingView = addLoadingView(view: view, x: Int(UIScreen.main.bounds.width * 0.42), y: 470)
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
                userAccount = account
                print(userAccount!)
                self.db.collection("users").whereField("account", isEqualTo: account).addSnapshotListener { (querySnapshot, error) in
                    removeLoadingView(loadingView)
                    for snapshot in querySnapshot!.documents {
                        let user = Users(dic: snapshot.data())
                        print(user.status!)
                        if user.status! == "0" {
                        print("A")
                            self.performSegue(withIdentifier: "signInToMain", sender: self)
                        } else if user.status! == "1" {
                            self.performSegue(withIdentifier: "signInToBackStage", sender: self)
                        } else {
                            let controller = UIAlertController(title: "此帳號已被停權", message: "請聯絡客服", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "確定", style: .default) { (action) in
                                
                            }
                            controller.addAction(ok)
                            self.present(controller,animated: true)
                        }
                    }
                }
            }
        }else {
            lbPassword.text = "帳號密碼未輸入，請再確認"
        }
    }
    @IBAction func btLoginFB(_ sender: UIButton) {
        manager = LoginManager()
        manager!.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            firebaseWorks.signInFireBaseWithFB { (result) in
                print("FB登入到Firebase",result)
            }
        }
//        manager.logIn(permissions: [.email,.publicProfile], viewController: self) { (result) in
//            print("result = ",result)
//            firebaseWorks.signInFireBaseWithFB { (result) in
//                print("result2 = ",result)
//            }
//        }
    }
    @IBAction func btLoginGoogle(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("google登入失敗",error.localizedDescription)
            return
        } else {
            print("google登入中")
            firebaseWorks.signInFireBaseWithGoogle(user: user) { (result) in
                print("google error = ",error)
                if result == Result.success {
                    print("google登入成功")
                    self.performSegue(withIdentifier: "signInToMain", sender: self)
                }
            }
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
