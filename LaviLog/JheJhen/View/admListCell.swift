//
//  admListCell.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/3.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class admListCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
