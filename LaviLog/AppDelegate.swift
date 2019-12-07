//
//  AppDelegate.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/23.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
//FB登入新增方法
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var result = true
        print("url",url)
        if (url.absoluteString.range(of: "facebook") != nil){
            result = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        } else if (url.absoluteString.range(of: "google") != nil){
            result = (GIDSignIn.sharedInstance()?.handle(url))!
        }
//        ApplicationDelegate.shared.application(app, open: url, options: options)
        return result
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()

//Google登入新增方法
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
          if let error = error {
            print("delegate有錯",error)
            return
          }
          guard let authentication = user.authentication else {
            print("這邊有錯")
            return }
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
      }
      func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
          print("google登入失敗")
      }
      
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

