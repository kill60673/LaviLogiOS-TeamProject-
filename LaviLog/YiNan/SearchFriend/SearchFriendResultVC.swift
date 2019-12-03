//
//  SearchFriendResultVC.swift
//  LaviLog
//
//  Created by 田乙男 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class SearchFriendResultVC: UIViewController {
    
    @IBOutlet weak var ivFriend: UIImageView!
    @IBOutlet weak var lbFriend: UILabel!
    
    var friend: Friend!
    var images = [String: UIImage]()
    
    //var imagePaths = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //let image = images[friend!.imagePath!]
        print("圖片圖片=",images[friend.imagePath!])
        ivFriend.image = images[friend.imagePath!]
        lbFriend.text = friend.name
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
