//
//  inputViewController.swift
//  NumberUpDown
//
//  Created by 조상호 on 2020/11/04.
//  Copyright © 2020 조상호. All rights reserved.
//

import Foundation
import UIKit

// 질문
protocol InputViewControllerDelegate: class {
    func didInputed(number: Int)
}

class inputViewController: UIViewController {
 
    @IBOutlet var currentValue: UILabel!
    @IBOutlet var correctRange: UILabel!
    
    var min = 0
    var max = 100
    var randnum = 0
    var result:String = ""
    
    let ad = UIApplication.shared.delegate as? AppDelegate
    // 질문
    weak var delegate: InputViewControllerDelegate?

    override func viewDidLoad() {
        currentValue.text = ""
        correctRange.text = "0 ~ 100"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var adMin = (ad?.paramMin)!     // viewDidload 밖에서 쓰면 안되는 이유?
        var adMax = (ad?.paramMax)!     // ''
        let adValue = (ad?.paramValue)!
        
        if result == "Up" && adMin < adValue {
            adMin = adValue
            ad?.paramMin = adValue
        } else if result == "Down" && adMax > adValue {
            adMax = adValue
            ad?.paramMax = adValue
        }
        correctRange.text = "\(adMin) ~ \(adMax)"
    }
    
    @IBAction func one(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "1"
        }
    }
    @IBAction func two(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "2"
        }
    }
    @IBAction func thr(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "3"
        }
    }
    @IBAction func four(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "4"
        }
    }
    @IBAction func five(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "5"
        }
    }
    @IBAction func six(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "6"
        }
    }
    @IBAction func sev(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "7"
        }
    }
    @IBAction func eig(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "8"
        }
    }
    @IBAction func nine(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "9"
        }
    }
    @IBAction func zero(_ sender: Any) {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "0"
        }
    }
    @IBAction func backSpace(_ sender: Any) {
        self.currentValue.text = String(self.currentValue.text?.dropLast() ?? "")
    }
    // 질문
    @IBAction func done(_ sender: Any) {
        guard let number = Int(self.currentValue.text ?? "") else { return }
        self.delegate?.didInputed(number: number)
        self.ad?.paramValue = number
        self.dismiss(animated: true)
    }

}
