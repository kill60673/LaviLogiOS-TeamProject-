//
//  DaiyInsert_ViewController_K.swift
//  LaviLog
//
//  Created by Kao on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//
//
import UIKit

//客製文字輸入匡
extension UITextField{
    func setPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setBottomBoder(){
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
//客製文字輸入匡




class DaiyInsert_ViewController_K: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var CurrentTime: UILabel!
    
    @IBOutlet weak var ansTextField: UITextField!
    
    @IBOutlet weak var loationTextField: UITextField!
    
    
    override func viewDidLoad() {
        
        //顯示在畫面上的日期
        super.viewDidLoad()
        let date = NSDate()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy年MM月dd日"
        let strNowTime = dateformatter.string(from: date as Date) as String
        CurrentTime.text = strNowTime
        
        
        //strDay是要給Firebase找日期用的
        dateformatter.dateFormat = "dd"
        let strDay = dateformatter.string(from: date as Date) as String
        print(strDay)
        
        
        
        //文字輸入匡底線
        ansTextField.setPadding()
        ansTextField.setBottomBoder()
        loationTextField.setPadding()
        loationTextField.setBottomBoder()
       
        
        
        //鍵盤事件
        addKeyboardObserver()
        
        
       
    }
    
   
    
    @IBAction func btLocation(_ sender: UIButton) {
        sender.isSelected.toggle()
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





//鍵盤事件
   //鍵盤事件，用擴展把來區分更好閱讀
   extension DaiyInsert_ViewController_K {

       //建立view上移的方法
       func addKeyboardObserver() {
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
           }
           
           @objc func keyboardWillShow(notification: Notification) {
               view.frame.origin.y = -340

           }
           
           @objc func keyboardWillHide(notification: Notification) {
               view.frame.origin.y = 0
           }
       
       
       
       
      
       
       //按return鍵盤掉下
           func textFieldShouldReturn(_ textField: UITextField) -> Bool {
               textField.resignFirstResponder()
            print("鍵盤掉下")
               return true
           }
       //按背景鍵盤掉下
           
           override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
               self.view.endEditing(true)
            
           }

   }

