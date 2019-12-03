//
//  ordersVC.swift
//  LaviLog
//
//  Created by 張哲禎 on 2019/11/30.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit
import Firebase

class ordersVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UISearchBarDelegate  {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    let db = Firestore.firestore()
    var orders = [Order]()
    var DicImages = [String:UIImage]()
    var isSearch = false
    var searchOrders = [Order]()
    var searchDicImages = [String:UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        downLoadFirebase()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOrders = [Order]()
        searchDicImages = [String:UIImage]()
        let text = searchBar.text ?? ""
        var index : Int
        if text == "" {
            isSearch = false
        } else {
            isSearch = true
            for i in 0..<orders.count {
                index = i
                if orders[i].productName.contains(text){
                    searchOrders.append(orders[i])
//                    searchImages.append(images[i])
                }
//                if order.productName.contains(text){
//                    searchOrders.append(order)
//                    isSearch = true
//                }
            }
            print(searchOrders.count)
            print(searchDicImages.count)
        }
        tv.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch{
            return searchOrders.count
        } else {
            return orders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCellId", for: indexPath) as! ordersTVCell
        var order:Order
        if isSearch{
            order = searchOrders[indexPath.row]
            if (searchDicImages.count - 1) >= indexPath.row {
                cell.ivPhoto.image = self.searchDicImages[order.imageUrl]
            } else {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (time) in
                    cell.ivPhoto.image = self.searchDicImages[order.imageUrl]
                }
            }
        } else {
            order = orders[indexPath.row]
            if (DicImages.count - 1) >= indexPath.row {
                cell.ivPhoto.image = self.DicImages[order.imageUrl]
            } else {
//                以防萬一設個兩秒timer讓表格再跑一次
                Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (time) in
                    cell.ivPhoto.image = self.DicImages[order.imageUrl]
                }
            }
        }
        cell.lbName.text = order.productName
        cell.lbPrice.text = "\(order.productPrice)"
        return cell
    }
    
    func downLoadFirebase(){
        db.collection("order").whereField("account", isEqualTo: Auth.auth().currentUser!.email!).addSnapshotListener { (QuerySnapshot, Error) in
            guard let QuerySnapshot = QuerySnapshot else {
                return
            }
            for querySnapshot in QuerySnapshot.documents {
                self.orders.append(Order(dic: querySnapshot.data()))
//                print(self.orders.description)
            }
            self.downloadPhoto(orders: self.orders)
         self.tv.reloadData()
        }
    }
    
    func downloadPhoto(orders:[Order]){
        for order in orders {
            let fileReference = Storage.storage().reference().child("\(order.imageUrl)")
            fileReference.getData(maxSize: .max) { (data, error) in
                if let data = data, let image = UIImage(data: data) {
                    self.DicImages[order.imageUrl] = image
                }else {
                    print(error?.localizedDescription as Any)
                }
                print("images.count",self.DicImages.count)
                self.tv.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let orderDetailVC = segue.destination as! orderDetailVC
        if isSearch{
            orderDetailVC.order = searchOrders[tv.indexPathForSelectedRow!.row]
            orderDetailVC.image = searchDicImages[searchOrders[tv.indexPathForSelectedRow!.row].imageUrl]
        } else {
            orderDetailVC.order = orders[tv.indexPathForSelectedRow!.row]
            orderDetailVC.image = DicImages[orders[tv.indexPathForSelectedRow!.row].imageUrl]
            print(orders[tv.indexPathForSelectedRow!.row].imageUrl)
            
        }
    }
}
struct Order {
    var account:String
    var imageUrl:String
    var productName:String
    var productPrice:Int
}
extension Order {
    init(dic:[String:Any]){
        self.account = dic["account"] as! String
        self.imageUrl = dic["imageUrl"] as! String
        self.productName = dic["productName"] as! String
        self.productPrice = dic["productPrice"] as! Int
    }
}

