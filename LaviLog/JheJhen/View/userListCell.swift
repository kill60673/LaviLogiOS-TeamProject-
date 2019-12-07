//
//  userListCell.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/2.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class userListCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
