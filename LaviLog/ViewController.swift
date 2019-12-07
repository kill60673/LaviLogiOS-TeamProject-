//1.storyBoard的textFiele要拉delegate到viewController

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {
    
   //宣告文字輸入匡
    @IBOutlet weak var tF: UITextField!
    
    @IBAction func bT(_ sender: UIButton) {
           //點擊按鈕後文字輸入匡會清空且鍵盤會落下
           tF.text = ""
           tF.resignFirstResponder()
       }
    
   override func viewDidLoad() {
       super.viewDidLoad()
       //監聽螢幕上移的方法
       addKeyboardObserver()
   }
}

//鍵盤事件，用擴展把來區分更好閱讀
extension ViewController {

    //建立view上移的方法
    func addKeyboardObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc func keyboardWillShow(notification: Notification) {
            view.frame.origin.y = -300

        }
        
        @objc func keyboardWillHide(notification: Notification) {
            view.frame.origin.y = 0
        }
    
    
    
    
   
    
    //按return鍵盤掉下
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    //按背景鍵盤掉下
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }

}


