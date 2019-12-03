//
//  NoticeTVC.swift
//  
//
//  Created by 田乙男 on 2019/12/2.
//

import UIKit
import Firebase

class NoticeTVC: UITableViewController {
    
    var images = [String: UIImage]()
    var notices = [Notice]()
    
    func getNotice() {
        var imagePaths = [String]()
        let db = Firestore.firestore()
        //        db.collection("songs").getDocuments { (querySnapshot, error) in
        // descending: true // true 降冪 大到小 原本默認 // false 升冪 小到大
        db.collection("notices").order(by: "noticeTime", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            self.notices = querySnapshot.documents.map {
                Notice(dic: $0.data())
            }
            
            self.tableView.reloadData()
            
            for snapshot in querySnapshot.documents {
                imagePaths.append(snapshot.data()["nImagePath"] as! String)
                print("path",imagePaths)
                
                for nImagePath in imagePaths {
                    let fileReference = Storage.storage().reference().child("\(nImagePath)")
                    print("filepath",fileReference)
                    fileReference.getData(maxSize: .max) { (data, error) in
                        if let data = data, let image = UIImage(data: data) {
                            self.images[nImagePath] = image
                            print("imagePath",nImagePath)
                            print("self.images",self.images)
                        }else {
                            print(error?.localizedDescription)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNotice()
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notices.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as! NoticeCell
        
        // Configure the cell...
        
        var notice: Notice?
        
        notice = notices[indexPath.row]
        cell.lbM.text = notice?.noticeMessage
        cell.lbM2.text = notice?.noticeMessage2
        cell.lbTime.text = notice?.noticeTime
        
        let image = images[notice!.nImagePath!]
        cell.ivNotice.image = image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    /* 設定可否編輯資料列 */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        //         if indexPath.row == 1{
        //             return false
        //         }
        //         //使第二個資料無法修改
        
        return true
    }
    
    /* 修改確定後，判斷編輯模式並作出回應 */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 按下Delete按鈕
        if editingStyle == .delete {
            notices.remove(at: indexPath.row)
            /* 提供array，儲存著欲刪除資料的indexPath。如果只刪除一筆資料，array內存放一個indexPath元素即可 */
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
}
