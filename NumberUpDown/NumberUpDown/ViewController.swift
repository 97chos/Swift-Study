//
//  ViewController.swift
//  NumberUpDown
//
//  Created by 조상호 on 2020/10/31.
//  Copyright © 2020 조상호. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var randNum = arc4random_uniform(100)
    var compareNum: Int = 0
    var failCount = 0
    
    override func viewDidLoad() {
        self.inputNum.delegate = self
        self.nthFail.text = ""
        self.result.text = ""
        // inputNum.becomeFirstResponder()
        self.inputNum.placeholder = "숫자를 입력하세요"
        self.inputNum.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBOutlet var inputNum: UITextField!
    @IBOutlet var result: UILabel!
    @IBOutlet var nthFail: UILabel!
    
    
    @IBAction func retry(_ sender: Any) {
        randNum = arc4random_uniform(100)
        self.result.text = ""
        self.nthFail.text = ""
        self.inputNum.text = ""
        failCount = 0
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.paramMin = 0
        ad?.paramMax = 100
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "ivc") as? inputViewController else {
            return
        }
        uvc.modalPresentationStyle = .fullScreen
        self.present(uvc, animated: true)
        textField.resignFirstResponder()
        
        uvc.randnum = Int(randNum)
        if result.text != nil {
            uvc.result = result.text!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if inputNum.text! != "" {
            compareNum = Int(inputNum.text!)!
            
            if compareNum > randNum {
                result.text = "Down"
                failCount += 1
                nthFail.text = "\(failCount)회 오답입니다."
            } else if compareNum < randNum {
                result.text = "Up"
                failCount += 1
                nthFail.text = "\(failCount)회 오답입니다."
            } else if compareNum == randNum {
                result.text = "Correct"
            }
        } else {
            result.text = "숫자를 입력해주세요."
        }
        print(randNum)
    }
}

