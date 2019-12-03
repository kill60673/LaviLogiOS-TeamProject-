//
//  orderDetailVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/1.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class orderDetailVC: UIViewController {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDetail: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    var order:Order?
    var image:UIImage?
    override func viewDidLoad() {
        print(order!)
        print(image)
        super.viewDidLoad()
        if order != nil && image != nil {
            ivPhoto.image = image
            lbName.text = "產品名稱為：\(order!.productName)"
            lbPrice.text = "購買價格為：\(order!.productPrice)"
        }
    }
}
