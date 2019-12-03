import UIKit

class GenQRCodeVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func clickGenerate(_ sender: Any) {
        let text = textField.text == nil ? "" : textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            imageView.image = nil
            textField.text = ""
            return
        }
        // 將文字轉成Data，編碼採ASCII
        let data = text.data(using: String.Encoding.ascii)
        // 建立CIFilter物件，準備產生QR code
        guard let ciFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        // 使用CIFilter產生QR code要給予key-"inputMessage", value-文字值
        ciFilter.setValue(data, forKey: "inputMessage")
        // 取得產生好的QR code圖片，不過圖片很小
        guard let ciImage_smallQR = ciFilter.outputImage else { return }
        
        // QR code圖片很小，需要放大
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let ciImage_largeQR = ciImage_smallQR.transformed(by: transform)
        // 將CIImage轉成UIImage顯示
        let uiImage = UIImage(ciImage: ciImage_largeQR)
        imageView.image = uiImage
    }
    
    @IBAction func didEndOnExit(_ sender: Any) { }
    
}

