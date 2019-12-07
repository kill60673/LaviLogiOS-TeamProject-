//
//  ordersTVCell.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/30.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class ordersTVCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
