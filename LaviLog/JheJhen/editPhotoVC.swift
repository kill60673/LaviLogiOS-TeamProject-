//
//  editPhotoVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/25.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class editPhotoVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var btConfirm: UIButton!
    @IBOutlet weak var ivPhoto: UIImageView!
    var isTakePicture = false
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadPhoto()
        loadingView.isHidden = true
    }
    @IBAction func btTakePicture(_ sender: UIButton) {
        isTakePicture = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true)
        
    }
    @IBAction func btPickPicture(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btConfirm(_ sender: UIButton) {
        loadingView.isHidden.toggle()
        uploadPhoto { (url) in
            if let url = url {
                self.btConfirm.isEnabled.toggle()
                self.loadingView.isHidden.toggle()
                self.navigationController?.popViewController(animated: true)
            } else {
                return
            }
        }
    }
    func uploadPhoto(completion: @escaping (URL?)->Void){
//        只留＠前的英文的話，使用下列方法
//        var imageName = ""
//        Auth.auth().currentUser?.email!.prefix(while: { (character) -> Bool in
//            if character != "@" {
//                imageName += String(character)
//                return true
//            } else {
//                return false
//            }
//            print(imageName)
//        })
        let fileReference = Storage.storage().reference().child("images_users/\(Auth.auth().currentUser!.email!).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if let data = ivPhoto.image?.jpegData(compressionQuality: 0.1) {
            fileReference.putData(data, metadata: metaData) { (storageMetadata, error) in
                guard error == nil else { return }
                fileReference.downloadURL { (url, error) in
                    completion(url)
                    guard let url = url else {
                        completion(nil)
                        return
                    }
                }
            }
        }
    }
    
    func downloadPhoto(){
        var imagePath = ""
        let db = Firestore.firestore()
        db.collection("users").whereField("account", isEqualTo: "\(Auth.auth().currentUser!.email!)").addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            for snapshot in querySnapshot.documents {
                imagePath = snapshot["imagePath"] as! String
//                print("imagePath =","\(imagePath)")
                let fileReference = Storage.storage().reference().child("\(imagePath)")
//                print("fileReference =",fileReference)
                fileReference.getData(maxSize: .max) { (data, error) in
                    if let data = data, let image = UIImage(data: data) {
                        self.ivPhoto.image = image
                    }else {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickImage = info[.originalImage] as? UIImage {
            ivPhoto.image = pickImage
            btConfirm.isEnabled = true
            if isTakePicture {
                UIImageWriteToSavedPhotosAlbum(pickImage, nil, nil, nil)
                isTakePicture = false
            }
            
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

