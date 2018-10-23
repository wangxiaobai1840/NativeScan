//
//  ViewController.swift
//  NativeScanDemo
//
//  Created by LC on 2018/9/1.
//  Copyright © 2018年 WLX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scanButton = UIButton.init(type: .custom)
        scanButton.setTitle("扫描", for: .normal)
        scanButton.setTitleColor(UIColor.blue, for: .normal)
        scanButton.frame = CGRect(x:(self.view.frame.width - 100)/2, y: 100, width: 100, height: 50)
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        self.view.addSubview(scanButton)
        
        let createQRCodeButton = UIButton.init(type: .custom)
        createQRCodeButton.setTitle("生成二维码", for: .normal)
        createQRCodeButton.setTitleColor(UIColor.blue, for: .normal)
        createQRCodeButton.frame = CGRect(x: (self.view.frame.width - 100)/2, y: scanButton.frame.maxY + 10, width: 100, height: 50)
        createQRCodeButton.addTarget(self, action: #selector(createQRCodeAction), for: .touchUpInside)
        self.view.addSubview(createQRCodeButton)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func createQRCodeAction(){
        self.navigationController?.pushViewController(CreateQRCodeViewController(), animated: true)
    }
    @objc func scanAction(){
        let scanController = ScanCodeViewController()
        self.navigationController?.pushViewController(scanController, animated: true)
    }
}

