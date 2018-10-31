//
//  CreateQRCodeViewController.swift
//  NativeScanDemo
//
//  Created by LC on 2018/10/23.
//  Copyright © 2018年 WLX. All rights reserved.
//

import UIKit
import AVFoundation

class CreateQRCodeViewController: UIViewController {

   fileprivate let qrCodeImageView:UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let image  = createQRCode(msg: "测试信息")
        qrCodeImageView.image = image
        qrCodeImageView.frame = CGRect(x: (self.view.frame.width - 200)/2, y: (self.view.frame.height - 200)/2, width: 200, height: 200)
        self.view.addSubview(qrCodeImageView)
    }
    // MARK: 二维码生成
    fileprivate func createQRCode(msg:String)->(UIImage){
        if msg.count > 0 {
            let msgData = msg.data(using: String.Encoding.utf8, allowLossyConversion: false)
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            qrFilter?.setValue(msgData, forKey: "inputMessage")
            qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
            let qrImage = qrFilter?.outputImage
            let colorFilter = CIFilter(name: "CIFalseColor")
            colorFilter?.setDefaults()
            colorFilter?.setValue(qrImage, forKey: "inputImage")
            colorFilter?.setValue(CIColor.init(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter?.setValue(CIColor.init(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            let codeImage:UIImage = UIImage(ciImage: colorFilter!.outputImage!.transformed(by: CGAffineTransform(scaleX: 5, y: 5)))
            
            // 添加中间的小图标
            let iconImage = UIImage.init(named: "test")
            let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
            UIGraphicsBeginImageContext(rect.size)
            codeImage.draw(in: rect)
            let iconSize = CGSize(width: rect.size.width * 0.2, height: rect.height*0.2)
            let x = (rect.width - iconSize.width)*0.5
            let y = (rect.height - iconSize.height)*0.5
            iconImage?.draw(in: CGRect(x: x, y: y, width: iconSize.width, height: iconSize.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resultImage!
        }
        return UIImage.init()
    }
}
