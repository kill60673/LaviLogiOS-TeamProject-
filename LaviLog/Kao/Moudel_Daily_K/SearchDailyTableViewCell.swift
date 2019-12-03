//
//  SearchDailyTableViewCell.swift
//  LaviLog
//
//  Created by Kao on 2019/12/3.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class SearchDailyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivDaily: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
