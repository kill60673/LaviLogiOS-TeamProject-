//
//  Notice.swift
//  
//
//  Created by 田乙男 on 2019/12/2.
//

import Foundation

struct Notice {
    var account: String?
    var nImagePath: String?
    var noticeMessage: String?
    var noticeMessage2: String?
    var noticeTime: String?
}

extension Notice {
    init(dic: [String: Any]) {
        account = dic["account"] as? String ?? ""
        nImagePath = dic["nImagePath"] as? String ?? ""
        noticeMessage = dic["noticeMessage"] as? String ?? ""
        noticeMessage2 = dic["noticeMessage2"] as? String ?? ""
        noticeTime = dic["noticeTime"] as? String ?? ""
    }
}
