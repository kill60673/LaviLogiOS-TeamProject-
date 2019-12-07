//
//  FuncLoadingView.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/12/4.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import Foundation
import UIKit

func addLoadingView(view: UIView,x :Int,y:Int)->UIView?{
    if let array = Bundle.main.loadNibNamed("loadingView", owner: nil, options: nil),let loadingView = array[0] as? UIView {
        loadingView.isHidden = false
        view.addSubview(loadingView)
        loadingView.frame.origin = CGPoint(x: x, y: y)
        return loadingView
    } else {
        return nil
    }
}

func removeLoadingView(_ loadingView:UIView?){
    if let  loadingView = loadingView {
     loadingView.removeFromSuperview()
    }
}
