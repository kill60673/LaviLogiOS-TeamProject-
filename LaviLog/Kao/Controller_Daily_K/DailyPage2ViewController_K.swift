//
//  DailyPage2ViewController_K.swift
//  LaviLog
//
//  Created by Kao on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class DailyPage2ViewController_K: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // Override point for customization after application launch.
                    //新增載入時顯示的圖片
                    let bgImageView = UIImageView()
                    bgImageView.image = UIImage(named: "bgImage")
                    
                    //設定圖片的大小範圍位置
                    bgImageView.frame = CGRect(x: 0, y: 0, width: (bgImageView.image?.size.width)!, height: view.frame.height)
                    
                    //在view上加上圖片
                    view.addSubview(bgImageView)
                    //把bgImageView放到最後層
                    view.sendSubviewToBack(bgImageView)
                    //再到AppDelegate.swift中設定UIWindow
              //withDuration動畫時間40秒
              UIView.animate(withDuration: 35, animations: {
                  //animations要做什麼樣的運動(從右到左x減)，跑完後會多一塊螢幕大小的黑畫面，再加一個螢幕大小的圖片補上去
                  bgImageView.center.x = bgImageView.center.x - (bgImageView.image?.size.width)! + (self.view.frame.width)
                  
                //completion動畫右像左後，再從左向右，因為右向左時會多出來的位置，所以在這邊要再減掉
              }) { (finished) in
                  //在finish之後要再加UIView及動畫效果，只要設時間及動畫就好
                  UIView.animate(withDuration: 35) {
                      bgImageView.center.x = bgImageView.center.x + (bgImageView.image?.size.width)! - (self.view.frame.width)
                      }
              }
    }
    
    @IBAction func btCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
