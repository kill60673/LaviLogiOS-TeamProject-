//
//  DaiyInsert_ViewController_K.swift
//  LaviLog
//
//  Created by Kao on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseStorage
import FirebaseFirestore



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





class DaiyInsert_ViewController_K: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {
    
    
    
    
    @IBOutlet weak var currentTime: UILabel!
    
    @IBOutlet weak var ansTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var dailyInsertImageView: UIImageView!
    
    @IBOutlet weak var todayQuestion: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    
    var locationManager:CLLocationManager?
    var location:CLLocation?
    
    let date = NSDate()
    let dateformatter = DateFormatter()
    
    //firestorage
    var storage:Storage!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        //firebase
        self.storage = Storage.storage()
        
        //匿名登入
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error{
                print("錯誤訊息：" + error.localizedDescription)
            }
        }
        
        //顯示在畫面上的日期
        dateformatter.dateFormat = "yyyy/MM/dd"
        let strNowTime = dateformatter.string(from: date as Date) as String
        currentTime.text = strNowTime
        
        
        //strDay是要給Firebase帶入每日問題
        dateformatter.dateFormat = "dd"
        let strDay = dateformatter.string(from: date as Date) as String
        print(strDay)
        
        //strMonth取月份
        dateformatter.dateFormat = "MM"
        let strMonth = dateformatter.string(from: date as Date) as String
        print(strMonth)
        
        //strYear取年
        dateformatter.dateFormat = "yyyy"
        let strYear = dateformatter.string(from: date as Date) as String
        print(strYear)
        
        
        //文字輸入匡底線
        ansTextField.setPadding()
        ansTextField.setBottomBoder()
        locationTextField.setPadding()
        locationTextField.setBottomBoder()
        
        
        
        //鍵盤事件
        addKeyboardObserver()
        
        
        //imageView放上相片
        dailyInsertImageView.image = UIImage(named: "no_image")
        dailyInsertImageView.isUserInteractionEnabled = true
        
        
        
        
        //呼叫每日問題
        let questionDb = Firestore.firestore()
        questionDb.collection("dailyQuestion").whereField("day", isEqualTo: strDay).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents{
                    self.todayQuestion.text = (document.data()["question"] as! String)
                    print(document.data())
                }
            }
        }
        
        
        
        
        
        
        //viewDidLoad的尾
    }
    
    
   
    
    
    
    
    //上傳照片的func
    func uploadPhoto(completion: @escaping (URL?) -> () ){
        let storageReference = Storage.storage().reference().child("images_daily/\(UUID().uuidString).png")
        //將dailyInsertImageView，再轉成data(UIImage轉data)，壓縮品質0.9
        if let data = dailyInsertImageView.image?.jpegData(compressionQuality: 0.9){
            storageReference.putData(data, metadata: nil) { (_, error) in
                guard  error == nil  else {return}
                storageReference.downloadURL { (url, error) in
                    completion(url)
                }
                
            }
            
        }
        
    }
    
    
    
    
    
  
    //發佈
    @IBAction func btPostDaily(_ sender: UIBarButtonItem) {
        
        //旋轉
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
       
        
        
        uploadPhoto { (url) in
            if let url = url{
                
                self.dateformatter.dateFormat = "dd"
                let strDay = self.dateformatter.string(from: self.date as Date) as String
                print(strDay)
                self.dateformatter.dateFormat = "MM"
                let strMonth = self.dateformatter.string(from: self.date as Date) as String
                print(strMonth)
                self.dateformatter.dateFormat = "yyyy"
                let strYear = self.dateformatter.string(from: self.date as Date) as String
                print(strYear)
                
                if self.ansTextField.text == ""  {
                    
                    self.ansTextField.resignFirstResponder()
                    
                    let postAlert = UIAlertController(title: "噢不！", message: "請回答今日問題", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "我知道了", style: .default) { (alerAction) in
                        
                    }
                    postAlert.addAction(ok)
                    self.present(postAlert,animated: true,completion: nil)
              
                    
                }else{
                    
       
                    
                    //新增日誌
                    self.ansTextField.resignFirstResponder()
                    let dailyDb = Firestore.firestore()
                    
                    let data:[String:Any] = ["account":"帳號不知道","answer":self.ansTextField.text as Any,"day":strDay as Any,"id":"id不知道","imagePath":url.absoluteString,"month":strMonth,"question":self.todayQuestion.text as Any,"textClock":self.currentTime.text as Any,"year":strYear,"location":self.locationTextField.text as Any]
                    var reference:DocumentReference?
                    reference = dailyDb.collection("article").addDocument(data: data) {(error) in
                        if let error = error{
                            print(error)
                        }else{
                            
                            print(reference?.documentID as Any)
                        }
                        
                    }
                   
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    
    
    
    
    
    
    //打卡
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate.latitude)
        print(locations[0].coordinate.longitude)
        let myLatitude = locations[0].coordinate.latitude
        let myLongitude = locations[0].coordinate.longitude
        //測試座標轉換成地址
        let location = CLLocation(latitude: myLatitude, longitude: myLongitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil,placemarks != nil else{
                return
            }
            for placemark in placemarks!{
                self.locationTextField.text = "\(placemark.name!)" 
            }
        }
        
    }
    
    //圖像擷取
    @IBAction func btShowImage(_ sender: UIButton) {
        let myAlert =  UIAlertController(title:"上傳照片",message:"請選擇上傳方式",preferredStyle: .actionSheet)
        //拍照
        let takePictureAction = UIAlertAction(title: "拍照", style: .default) { (action:UIAlertAction) in
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker,animated: true,completion: nil)
        }
        //相簿
        let picPictureAction = UIAlertAction(title: "從相簿中選取", style: .default) { (action:UIAlertAction) in
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            //照片編輯器
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker,animated: true,completion: nil)
            
            
            
        }
        //alert取消
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        //把按鈕放在警告控制器中
        myAlert.addAction(takePictureAction)
        myAlert.addAction(picPictureAction)
        myAlert.addAction(cancelAction)
        
        present(myAlert, animated: true, completion: nil)
        
    }
    //把照片放到imageView上的方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //可將照片切割成正方形
        if let pickedImage = info[.editedImage] as? UIImage{
            dailyInsertImageView.image = pickedImage
            UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btClearImage(_ sender: UIButton) {
        dailyInsertImageView.image = UIImage(named: "no_image")
    }
    
    
    @IBAction func btLocation(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        if sender.isSelected{
            //打卡
            locationManager = CLLocationManager()
            //請求使用者授權讓app拿到手機位置相關資訊
            locationManager?.requestWhenInUseAuthorization()
            //把自己(ViewController)當作locationManager的屬性
            locationManager?.delegate = self
            //設定精準度
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            //設定活動模式
            locationManager?.activityType = .automotiveNavigation
            //每次手機移動、定點更新時觸發startUpdatingLocation()方法
            locationManager?.startUpdatingLocation()
            //得知目前座標
            if let coordinate = locationManager?.location?.coordinate{
                //產生放大縮小比例
                let xScale:CLLocationDegrees = 0.01
                let yScale:CLLocationDegrees = 0.01
                let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: yScale, longitudeDelta: xScale)
                let regin = MKCoordinateRegion(center: coordinate, span: span)
                //讓地圖顯示
            }
            
            
            //打卡
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                print(locations[0].coordinate.latitude)
                print(locations[0].coordinate.longitude)
                let myLatitude = locations[0].coordinate.latitude
                let myLongitude = locations[0].coordinate.longitude
                //測試座標轉換成地址
                let location = CLLocation(latitude: myLatitude, longitude: myLongitude)
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    guard error == nil,placemarks != nil else{
                        return
                    }
                    for placemark in placemarks!{
                        self.locationTextField.text = "\(placemark.name!)"
                    }
                }
                
            }
        }else{
            locationTextField.text = ""
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager?.stopUpdatingLocation()
    }
    
    
    
    
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

