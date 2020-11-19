//
//  NumberGame.swift
//  gameNReminders
//
//  Created by sangho Cho on 2020/11/15.
//

import Foundation
import UIKit
import SnapKit

class NumberGame: UIViewController, UITextFieldDelegate {
    var inputNum = UITextField()
    var result = UILabel()
    var nthfail = UILabel()
    var reset = UIButton()
    var randNum = arc4random_uniform(100)
    var compareNum: Int = 0
    var failCount = 0
    let ad = UIApplication.shared.delegate as? AppDelegate


    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.view.addSubview(inputNum)
        self.view.addSubview(result)
        self.view.addSubview(nthfail)
        self.view.addSubview(reset)
        self.inputNum.delegate = self
        self.title = "NumberGame"
        inputNumLayout()
        resultLayout()
        nthfailLayout()
        resetLayout()

        reset.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if inputNum.text != "" {
            compareNum = Int(inputNum.text!)!
            print(compareNum)

            if compareNum > randNum {
                result.text = "Down"
                failCount += 1
                nthfail.text = "\(failCount)회 오답입니다."
            } else if compareNum < randNum {
                result.text = "Up"
                failCount += 1
                nthfail.text = "\(failCount)회 오답입니다."
            } else if compareNum == randNum {
                result.text = "correct"
            }
        } else {
            result.text = "숫자를 입력해주세요."
        }
    }

    func inputNumLayout() {
        self.inputNum.borderStyle = .roundedRect
        inputNum.snp.makeConstraints(){
            $0.leading.equalToSuperview().offset(70)
            $0.trailing.equalToSuperview().offset(-70)
            $0.height.equalTo(30)
            $0.top.equalToSuperview().offset(250)
        }
    }

    func resultLayout() {
        self.result.text = "숫자를 입력하세요 (0~99)"
        self.result.textAlignment = .center
        self.result.textColor = .black
        result.snp.makeConstraints() {
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.inputNum.snp.bottom).offset(30)
        }
    }

    func nthfailLayout() {
        self.nthfail.text = ""
        self.nthfail.textColor = .black
        self.nthfail.textAlignment = .center
        nthfail.snp.makeConstraints() {
            $0.top.equalTo(self.result.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
    }

    func resetLayout() {
        self.reset.setTitle("Reset", for: .normal)
        self.reset.setTitleColor(.systemBlue, for: .normal)
        reset.snp.makeConstraints() {
            $0.width.equalTo(60)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.nthfail.snp.bottom).offset(25)
        }

    }

    @objc func resetAction() {
        randNum = arc4random_uniform(100)
        self.result.text = "숫자를 입력해주세요."
        self.nthfail.text = ""
        self.inputNum.text = ""
        failCount = 0

        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.paramMin = 0
        ad?.paramMax = 100
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let ivc = inputNumViewController()

        if result.text != nil {
            ivc.result = self.result.text!
        }
        ivc.modalPresentationStyle = .fullScreen
        self.inputNum.resignFirstResponder()
        self.present(ivc, animated: true)
    }
}

extension NumberGame: inputNumDelegate {
    func didInputed(number: Int) {
        self.inputNum.text = "\(number)"
    }
}
