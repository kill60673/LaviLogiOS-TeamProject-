//
//  NoticeCell.swift
//  LaviLog
//
//  Created by 田乙男 on 2019/12/2.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class NoticeCell: UITableViewCell {

    @IBOutlet weak var ivNotice: UIImageView!
    @IBOutlet weak var lbM: UILabel!
    @IBOutlet weak var lbM2: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //標籤圓角
//        lbM.layer.cornerRadius = 12
//        lbM.layer.masksToBounds = true
        
//        lbM2.layer.cornerRadius = 12
//        lbM2.layer.masksToBounds = true
        // cell 圓角
        self.layer.cornerRadius = 50
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
