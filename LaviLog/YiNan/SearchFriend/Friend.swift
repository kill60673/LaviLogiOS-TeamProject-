//
//  Friend.swift
//  LaviLog
//
//  Created by 田乙男 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import Foundation

struct Friend {
    var imagePath: String?
    var name: String?
}

extension Friend {
    init(dic: [String: Any]) {
        imagePath = dic["imagePath"] as? String ?? ""
        name = dic["name"] as? String ?? ""
    }
}
