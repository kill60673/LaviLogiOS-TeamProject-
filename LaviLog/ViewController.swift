//
//  ViewController.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/23.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase
//
class ViewController: UIViewController {
    //123

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    let db = Firestore.firestore()
        db.collection("article").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents{
                    print(document.data())
                }
            }
        }
    }
}

