//
//  QRCodeViewController.swift
//  NativeScanDemo
//
//  Created by LC on 2018/10/23.
//  Copyright © 2018年 WLX. All rights reserved.
//

import UIKit
import AVFoundation

let KScreenWidth:CGFloat = UIScreen.main.bounds.width
let KScreenHeight:CGFloat = UIScreen.main.bounds.height
let ALScanWidth:CGFloat = 514/2 // 扫描框宽度
let ALScanViewY:CGFloat = (KScreenHeight - ALScanWidth)/2
let ALScanViewX:CGFloat = (KScreenWidth - ALScanWidth)/2
let ALScanLineHeight:CGFloat = 6
let ALScanLineLeftAndRightMargin:CGFloat = 15

class ScanCodeViewController: UIViewController {
    var scanDevice: AVCaptureDevice?
    var scanInput: AVCaptureDeviceInput?
    var scanOutput: AVCaptureMetadataOutput?
    var scanSession: AVCaptureSession?
    var scanPreviewLayer: AVCaptureVideoPreviewLayer?
    var scanLineView:UIImageView?
    var scanBgView:UIView?
    var timer:DispatchSourceTimer!
    var flashlight:UIButton!
    var createQRCodeButton:UIButton! // 生成二维码
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createScanView()
        initScanView()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer.suspend()
        self.scanSession?.stopRunning()
    }
    
    func initScanView(){
        self.scanDevice = AVCaptureDevice.default(for: .video)
        do {
            self.scanInput = try? AVCaptureDeviceInput(device: self.scanDevice!)
            guard self.scanInput != nil else {
                return
            }
            self.scanOutput = AVCaptureMetadataOutput()
            self.scanOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.scanSession = AVCaptureSession()
            if self.scanDevice?.supportsSessionPreset(AVCaptureSession.Preset.hd4K3840x2160) == true{
                self.scanSession?.canSetSessionPreset(.high)
            }else if scanDevice?.supportsSessionPreset(AVCaptureSession.Preset.hd4K3840x2160) == false{
                if scanDevice?.supportsSessionPreset(AVCaptureSession.Preset.hd1920x1080) == true {
                    self.scanSession?.canSetSessionPreset(.hd1920x1080)
                }else{
                    self.scanSession?.canSetSessionPreset(.hd1280x720)
                }
            }
            
            if (self.scanSession?.canAddInput(self.scanInput!))! {
                self.scanSession?.addInput(self.scanInput!)
            }
            if (self.scanSession?.canAddOutput(self.scanOutput!))! {
                self.scanSession?.addOutput(self.scanOutput!)
            }
            
            self.scanOutput?.metadataObjectTypes = [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.code93,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.ean13
            ]
            
            self.scanPreviewLayer = AVCaptureVideoPreviewLayer(session:self.scanSession!)
            self.scanPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.scanPreviewLayer?.frame = self.view.layer.bounds
            view.layer.insertSublayer(self.scanPreviewLayer!, at: 0)
            if (self.scanDevice?.isFocusModeSupported(.autoFocus))! {
                do{
                    try self.scanInput?.device.lockForConfiguration()
                }catch{}
                //                self.scanInput?.device.focusMode = .autoFocus // 自动聚焦
                self.scanInput?.device.focusMode = .continuousAutoFocus // 自动持续聚焦
                self.scanInput?.device.unlockForConfiguration()
            }
            
            if !(self.scanSession?.isRunning)! {
                self.scanSession?.startRunning()
            }
            // 注意扫描区域设置要在扫描startRunning之后
            self.scanOutput?.rectOfInterest =
                (self.scanPreviewLayer?.metadataOutputRectConverted(fromLayerRect:self.scanRect()))! // 设置扫描区域
        } catch {
            return
        }
    }
    
    //  确定扫描区域
    func scanRect()->(CGRect){
        
        return CGRect(x: ALScanViewX, y: ALScanViewY, width:ALScanWidth, height: ALScanWidth)
    }
    
    // MARK: 扫描界面
    func createScanView(){
        
        if scanBgView == nil {
            self.scanBgView = UIView()
            self.scanBgView?.frame = self.view.frame
            self.scanBgView?.backgroundColor = UIColor.clear
            self.view.addSubview(self.scanBgView!)
            let topView = UIView()
            topView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            topView.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: (KScreenHeight - ALScanWidth)/2)
            self.scanBgView?.addSubview(topView)
            
            let leftView = UIView()
            leftView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            leftView.frame = CGRect(x: 0, y: ALScanViewY, width:ALScanViewX, height: ALScanWidth)
            self.scanBgView?.addSubview(leftView)
            
            let rightView = UIView()
            rightView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            rightView.frame = CGRect(x: ALScanViewX + ALScanWidth , y: ALScanViewY, width:ALScanViewX, height: ALScanWidth)
            self.scanBgView?.addSubview(rightView)
            
            let bottomView = UIView()
            bottomView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            bottomView.frame = CGRect(x: 0 , y: KScreenHeight - ALScanViewY, width:KScreenWidth, height: ALScanViewY)
            self.scanBgView?.addSubview(bottomView)
            
            let scanView = UIImageView.init(image: UIImage.init(named: "ticket_scan_border"))
            scanView.backgroundColor = UIColor.clear
            scanView.frame = scanRect()
            self.scanBgView?.addSubview(scanView)
            
            let noteButton = UIButton()
            noteButton.setTitle("将二维码放入框内", for: .normal)
            noteButton.layer.borderColor = UIColor.lightGray.cgColor
            noteButton.layer.borderWidth = 0.5
            noteButton.layer.cornerRadius = 12.5
            noteButton.clipsToBounds = true
            noteButton.titleLabel?.textAlignment = .center
            noteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.scanBgView?.addSubview(noteButton)
            noteButton.frame = CGRect(x: (KScreenWidth - 126)/2, y: scanView.frame.maxY + 25, width: 126, height: 26)
            
            if flashlight == nil {
                flashlight = UIButton()
                self.view.addSubview(flashlight)
                flashlight.setImage(UIImage.init(named: "ticket_scan_flashlight_off"), for: .normal)
                flashlight.setImage(UIImage.init(named: "ticket_scan_flashlight_on"), for: .selected)
                flashlight.setTitleColor(UIColor.white, for: .normal)
                flashlight.setTitleColor(UIColor.blue, for: .selected)
                flashlight.setTitle("轻点照亮", for: .normal)
                flashlight.imageView?.contentMode = .scaleAspectFill
                flashlight.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                flashlight.imageEdgeInsets = UIEdgeInsetsMake(-20-8/2, 0, 0, -58)
                flashlight.titleEdgeInsets = UIEdgeInsetsMake(46 + 8/2, (-16), 0, 0)
                flashlight.isSelected = false
                flashlight.addTarget(self, action: #selector(flashlightAction), for: .touchUpInside)
                flashlight.frame = CGRect(x: (KScreenWidth - 58)/2 , y: noteButton.frame.maxY + 10 , width: 58, height: 74)
                
            }
            self.scanLineView = UIImageView.init(image: UIImage.init(named: "ticket_scan_line"))
            self.scanLineView?.frame = CGRect(x: ALScanViewX + ALScanLineLeftAndRightMargin, y: ALScanViewY + 6 , width: ALScanWidth - ALScanLineLeftAndRightMargin*2, height: ALScanLineHeight)
            self.scanBgView?.addSubview(self.scanLineView!)
        }
        if self.timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timer.schedule(deadline: .now(), repeating: 0.01)
            timer.setEventHandler {
                DispatchQueue.main.async {
                    if (self.scanLineView?.frame.origin.y)! + 1 > (KScreenHeight - ALScanViewY - ALScanLineHeight - 6*2){
                        self.scanLineView?.frame.origin.y = ALScanViewY + 6
                    }else{
                        self.scanLineView?.frame.origin.y += 1
                    }
                }
            }
        }
        
        self.timer.resume()
        self.view.addSubview(self.scanBgView!)
        self.view.sendSubview(toBack: self.scanBgView!)
    }
    
    // MARK: 手电筒开启关闭
    @objc func flashlightAction(){
        if (self.scanDevice?.hasTorch)! && (self.scanDevice?.isTorchAvailable)! {
            try? self.scanDevice?.lockForConfiguration()
            if self.scanDevice?.torchMode == .off {
                self.scanDevice?.torchMode = .on
                self.flashlight.isSelected = true
            } else {
                self.scanDevice?.torchMode = .off
                self.flashlight.isSelected = false
            }
            self.scanDevice?.unlockForConfiguration()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: 扫描结果输出
extension ScanCodeViewController:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.scanSession?.stopRunning()
        if metadataObjects.count > 0 {
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                self.alertMsg(msg: resultObj.stringValue!)
            }
        }
        self.scanSession?.stopRunning()
    }
    
    func alertMsg(msg:String){
        let alert = UIAlertController.init(title: "扫描结果", message: msg, preferredStyle: .alert)
        let cancleAction = UIAlertAction.init(title: "确认", style: .cancel) { (alert) in
            if !(self.scanSession?.isRunning)! {
                self.scanSession?.startRunning()
            }
        }
        alert.addAction(cancleAction)
        self.present(alert, animated: true) {
            
        }
        
    }
}
