//
//  DateTableViewCell.swift
//  LaviLog
//
//  Created by Kao on 2019/11/28.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
