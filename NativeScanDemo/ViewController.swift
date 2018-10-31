//
//  ViewController.swift
//  NativeScanDemo
//
//  Created by LC on 2018/9/1.
//  Copyright © 2018年 WLX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scanButton = createButton(title: "扫描", y: 100, tag: 100)
        let createQRCodeButton = createButton(title: "生成二维码", y: scanButton.frame.maxY + 10, tag: 101)
        let _ = createButton(title: "相册中选择", y: createQRCodeButton.frame.maxY + 10, tag: 102)
        
    }
    
    fileprivate func createButton(title:String,y:CGFloat,tag:NSInteger)->UIButton{
        let button = UIButton.init(type: .custom)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: (self.view.frame.width - 100)/2, y: y, width: 100, height: 50)
        button.addTarget(self, action: #selector(createQRCodeAction(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
        return button
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func createQRCodeAction(sender:UIButton){
        if sender.tag == 100 {
            self.navigationController?.pushViewController(ScanCodeViewController(), animated: true)
        }else if sender.tag == 101{
            self.navigationController?.pushViewController(CreateQRCodeViewController(), animated:true)
        }else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                if imagePicker == nil {
                    imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                }
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK:图片识别
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let ciimage = CIImage(cgImage: image.cgImage!)
        let options = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
        let featutes:Array = (detector?.features(in: ciimage, options: nil))!
        var resultString:String = ""
        for item in featutes{
            if item.isKind(of: CIQRCodeFeature.classForCoder()){
                resultString = resultString + "  &&  " + (item as! CIQRCodeFeature).messageString!
            }
        }
        if resultString.count > 0 {
            alertMsg(msg: resultString)
        }else {
            alertMsg(msg: "未识别到二维码")
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    func alertMsg(msg:String){
        let alert = UIAlertController.init(title: "提示", message: msg, preferredStyle: .alert)
        let cancleAction = UIAlertAction.init(title: "确认", style: .cancel) { (alert) in
        }
        alert.addAction(cancleAction)
        self.present(alert, animated: true) {
            
        }
    }
}

