//
//  FirebaseWorks.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation
import Firebase
import FacebookLogin
import FacebookCore
import GoogleSignIn
var userAccount:String!

//import GoogleSignIn

let firebaseWorks = FirebaseWorks()
enum Result{
    case success
    case fail
    case fail_changePW
}
class FirebaseWorks{
    func signInFireBaseWithFB(completion: @escaping (_ result: Result) -> ()){
        let fbAccessToken = AccessToken.current
        guard let fbAccessTokenString = fbAccessToken?.tokenString else { return }
        let fbCredentials = FacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        firebaseSignInWithCredential(credential: fbCredentials, completion: completion)
    }
    
    func signInFireBaseWithGoogle(user: GIDGoogleUser,completion: @escaping (_ result: Result) -> ()){
        print("google1")
        guard let authentication = user.authentication else { return }
        let googleCredential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print("google2")
        firebaseSignInWithCredential(credential: googleCredential, completion: completion)
    }

    func firebaseSignInWithCredential(credential: AuthCredential,completion: @escaping (_ result: Result) -> ()){
        print("google3")
        Auth.auth().signIn(with: credential, completion: { (profile, error) in
            if error != nil {
                //登入失敗 請重新登入
                completion(Result.fail_changePW)
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }else{
                completion(Result.success)
                let user = profile?.user
                print(profile?.credential!)
                print("Successfully logged in with our user: ", user ?? "")
                
                let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large)"])
                request.start { (response, result, error) in
                    var imagePathString = "no_image.jpg"
                    if let result = result as? [String : Any] {
                        print("account",result["email"] as! String)
                        userAccount = result["email"] as! String
                        var data = Data()
//                        若沒有照片檔案可以讀取，就讓要傳的data為空值
                        if let imageURLString = ((result["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                            if let imageURL = URL(string: imageURLString),let imageData = try? Data(contentsOf: imageURL) {
                                 imagePathString = "/images_users/\(userAccount!).jpg"
                                 data = imageData
                            }
                        }
                        print("看userAccount",userAccount!)
                        let db = Firestore.firestore()
                        let reference = db.collection("users").document()
                        let id = reference.documentID
                        let dicFirebase = ["account":userAccount,"birthDay":"未填","gender":"未填","id":id,"imagePath":imagePathString,"name":user?.displayName,"password":"FB","phone":"未填","status":"0","verificationCode":"","verificationId":""]
                        db.collection("users").whereField("account", isEqualTo: userAccount!).getDocuments { (querySnapshot, error) in
                            if let querySnapshot = querySnapshot {
                               let document = querySnapshot.documents.first
                                if  document != nil{
                                    print("不用再存 ",document)
                                }else{
                                    let imagePath = Storage.storage().reference().child("images_users/\(userAccount!).jpg")
                                    let metaData = StorageMetadata()
                                    metaData.contentType = "image/jpg"
                                    imagePath.putData(data, metadata: metaData) { (data, error) in
                                        guard error == nil else { return }
                                        print("照片放成功")
                                        imagePath.downloadURL { (url, error) in
                                            print("\(url!)")
                                        }
                                    }
                                    db.collection("users").document(id).setData(dicFirebase) { (error) in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                        } else {
                                            print("資料有存成功")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}
