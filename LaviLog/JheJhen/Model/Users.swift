//
//  Users.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/30.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import Foundation

struct Users{
    var account:String?
    var birthDay:String?
    var gender:String?
    var id:String?
    var imagePath:String?
    var name:String?
    var password:String?
    var phone:String?
    var status:String?
    var verificationCode:String?
    var verificationId:String?
}

extension Users {
    init(dic:[String:Any]){
        self.account = dic["account"] as? String ?? ""
        self.birthDay = dic["birthDay"] as? String ?? ""
        self.gender = dic["gender"] as? String ?? ""
        self.id = dic["id"] as? String ?? ""
        self.imagePath = dic["imagePath"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.password = dic["password"] as? String ?? ""
        self.phone = dic["phone"] as? String ?? ""
        self.status = dic["status"] as? String ?? ""
        self.verificationCode = dic["verificationCode"] as? String ?? ""
        self.verificationId = dic["verificationId"] as? String ?? ""
    }
}
