//
//  inputNumViewController.swift
//  gameNReminders
//
//  Created by sangho Cho on 2020/11/15.
//

import Foundation
import UIKit
import SnapKit

protocol inputNumDelegate: class {
    func didInputed(number: Int)
}

class inputNumViewController: UIViewController {
    var currentTitle = UILabel()
    var currentValue = UILabel()
    var correctTitle = UILabel()
    var correctRange = UILabel()

    var zero = UIButton()
    var one = UIButton()
    var two = UIButton()
    var thr = UIButton()
    var four = UIButton()
    var five = UIButton()
    var six = UIButton()
    var sev = UIButton()
    var eig = UIButton()
    var nine = UIButton()
    var delete = UIButton()
    var done = UIButton()

    let ad = UIApplication.shared.delegate as? AppDelegate
    var delegate: inputNumDelegate?
    var result = ""

    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.view.addSubview(currentTitle)
        self.view.addSubview(currentValue)
        self.view.addSubview(correctTitle)
        self.view.addSubview(correctRange)
        self.view.addSubview(one)
        self.view.addSubview(two)
        self.view.addSubview(thr)
        self.view.addSubview(four)
        self.view.addSubview(five)
        self.view.addSubview(six)
        self.view.addSubview(sev)
        self.view.addSubview(eig)
        self.view.addSubview(nine)
        self.view.addSubview(delete)
        self.view.addSubview(zero)
        self.view.addSubview(done)

        currentTitleLayout()
        currentValueLayout()
        correctTitleLayout()
        correctRangeLayout()
        oneLayout()
        twoLayout()
        thrLayout()
        fourLayout()
        fiveLayout()
        sixLayout()
        sevLayout()
        eigLayout()
        nineLayout()
        deleteLayout()
        zeroLayout()
        doneLayout()

        one.addTarget(self, action: #selector(oneAction), for: .touchUpInside)
        two.addTarget(self, action: #selector(twoAction), for: .touchUpInside)
        thr.addTarget(self, action: #selector(thrAction), for: .touchUpInside)
        four.addTarget(self, action: #selector(fourAction), for: .touchUpInside)
        five.addTarget(self, action: #selector(fiveAction), for: .touchUpInside)
        six.addTarget(self, action: #selector(sixAction), for: .touchUpInside)
        sev.addTarget(self, action: #selector(sevAction), for: .touchUpInside)
        eig.addTarget(self, action: #selector(eigAction), for: .touchUpInside)
        nine.addTarget(self, action: #selector(nineAction), for: .touchUpInside)
        zero.addTarget(self, action: #selector(zeroAction), for: .touchUpInside)
        delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        done.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        var adMin = (ad?.paramMin)!
        var adMax = (ad?.paramMax)!
        let adValue = (ad?.paramValue)!

        if result == "Up" && adMin < adValue {
            adMin = adValue
            ad?.paramMin = adValue
        } else if result == "Down" && adMax > adValue {
            adMax = adValue
            ad?.paramMin = adValue
        }
        correctRange.text = "\(adMin) ~ \(adMax)"
    }

    func currentTitleLayout() {
        currentTitle.text = "현재 입력 값"
        currentTitle.textColor = .black
        currentTitle.textAlignment = .center
        currentTitle.snp.makeConstraints() {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
    }

    func currentValueLayout() {
        currentValue.text = ""
        currentValue.font.withSize(30)
        currentValue.textColor = .black
        currentValue.textAlignment = .center
        currentValue.snp.makeConstraints() {
            $0.top.equalTo(currentTitle.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
    }

    func correctTitleLayout() {
        correctTitle.text = "정답 범위"
        correctTitle.textColor = .black
        correctTitle.textAlignment = .center
        correctTitle.snp.makeConstraints() {
            $0.top.equalTo(currentValue.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
    }

    func correctRangeLayout() {
        correctRange.text = "0 ~ 100"
        currentValue.font.withSize(30)
        correctRange.textColor = .black
        correctRange.textAlignment = .center
        correctRange.snp.makeConstraints() {
            $0.top.equalTo(correctTitle.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
/*
    func stackView(type: NSLayoutConstraint.Axis) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = space

        stack.addArrangedSubview(one)
        stack.addArrangedSubview(two)
        stack.addArrangedSubview(thr)
        stack.addArrangedSubview(four)
        stack.addArrangedSubview(five)
        stack.addArrangedSubview(six)
        stack.addArrangedSubview(sev)
        stack.addArrangedSubview(eig)
        stack.addArrangedSubview(nine)
        stack.addArrangedSubview(delete)
        stack.addArrangedSubview(zero)
        stack.addArrangedSubview(done)

        return stack
    }
*/
    func oneLayout() {
        one.setTitle("1", for: .normal)
        one.setTitleColor(.systemBlue, for: .normal)
        one.contentHorizontalAlignment = .center
        one.snp.makeConstraints() {
            $0.top.equalToSuperview().offset(300)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(two.snp.leading).offset(10)
            $0.width.equalTo(two.snp.width)
            $0.height.equalTo(four.snp.height)
            $0.bottom.equalTo(four.snp.top).offset(10)
        }
    }
    func twoLayout() {
        two.setTitle("2", for: .normal)
        two.setTitleColor(.systemBlue, for: .normal)
        two.snp.makeConstraints() {
            $0.top.equalToSuperview().offset(300)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(thr.snp.width)
            $0.height.equalTo(five.snp.height)
            $0.bottom.equalTo(five.snp.top).offset(10)
        }
    }
    func thrLayout() {
        thr.setTitle("3", for: .normal)
        thr.setTitleColor(.systemBlue, for: .normal)
        thr.snp.makeConstraints() {
            $0.top.equalToSuperview().offset(300)
            $0.leading.equalTo(two.snp.trailing).offset(-10)
            $0.height.equalTo(six.snp.height)
            $0.bottom.equalTo(six.snp.top).offset(10)
        }
    }
    func fourLayout() {
        four.setTitle("4", for: .normal)
        four.setTitleColor(.systemBlue, for: .normal)
        four.snp.makeConstraints() {
            $0.top.equalTo(one.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(five.snp.leading).offset(10)
            $0.width.equalTo(five.snp.width)
            $0.height.equalTo(sev.snp.height)
            $0.bottom.equalTo(sev.snp.top).offset(10)
        }
    }
    func fiveLayout() {
        five.setTitle("5", for: .normal)
        five.setTitleColor(.systemBlue, for: .normal)
        five.snp.makeConstraints() {
            $0.top.equalTo(two.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(six.snp.width)
            $0.height.equalTo(eig.snp.height)
            $0.bottom.equalTo(eig.snp.top).offset(10)
        }
    }
    func sixLayout() {
        six.setTitle("6", for: .normal)
        six.setTitleColor(.systemBlue, for: .normal)
        six.snp.makeConstraints() {
            $0.top.equalTo(thr.snp.bottom).offset(10)
            $0.leading.equalTo(five.snp.trailing).offset(-10)
            $0.height.equalTo(nine.snp.height)
            $0.bottom.equalTo(nine.snp.top).offset(10)
        }
    }
    func sevLayout() {
        sev.setTitle("7", for: .normal)
        sev.setTitleColor(.systemBlue, for: .normal)
        sev.snp.makeConstraints() {
            $0.top.equalTo(four.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(eig.snp.leading).offset(10)
            $0.width.equalTo(five.snp.width)
            $0.height.equalTo(delete.snp.height)
            $0.bottom.equalTo(delete.snp.top).offset(10)
        }
    }
    func eigLayout() {
        eig.setTitle("8", for: .normal)
        eig.setTitleColor(.systemBlue, for: .normal)
        eig.snp.makeConstraints() {
            $0.top.equalTo(five.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(nine.snp.width)
            $0.height.equalTo(zero.snp.height)
            $0.bottom.equalTo(zero.snp.top).offset(10)
        }
    }
    func nineLayout() {
        nine.setTitle("9", for: .normal)
        nine.setTitleColor(.systemBlue, for: .normal)
        nine.snp.makeConstraints() {
            $0.top.equalTo(six.snp.bottom).offset(10)
            $0.leading.equalTo(eig.snp.trailing).offset(-10)
            $0.height.equalTo(done.snp.height)
            $0.bottom.equalTo(done.snp.top).offset(10)
        }
    }
    func deleteLayout() {
        delete.setTitle("Delete", for: .normal)
        delete.setTitleColor(.systemBlue, for: .normal)
        delete.snp.makeConstraints() {
            $0.top.equalTo(sev.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(zero.snp.leading).offset(10)
            $0.width.equalTo(zero.snp.width)
            $0.bottom.equalToSuperview().offset(-50)
        }
    }
    func zeroLayout() {
        zero.setTitle("0", for: .normal)
        zero.setTitleColor(.systemBlue, for: .normal)
        zero.snp.makeConstraints() {
            $0.top.equalTo(eig.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(done.snp.width)
            $0.bottom.equalToSuperview().offset(-50)
        }
    }
    func doneLayout() {
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.systemBlue, for: .normal)
        done.snp.makeConstraints() {
            $0.top.equalTo(nine.snp.bottom).offset(10)
            $0.leading.equalTo(zero.snp.trailing).offset(-10)
            $0.bottom.equalToSuperview().offset(-50)
        }
    }

    @objc func oneAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "1"
        }
    }
    @objc func twoAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "2"
        }
    }
    @objc func thrAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "3"
        }
    }
    @objc func fourAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "4"
        }
    }
    @objc func fiveAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "5"
        }
    }
    @objc func sixAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "6"
        }
    }
    @objc func sevAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "7"
        }
    }
    @objc func eigAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "8"
        }
    }
    @objc func nineAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "9"
        }
    }
    @objc func zeroAction() {
        if currentValue.text!.count > 1 {
            currentValue.text? += ""
        } else {
            currentValue.text? += "0"
        }
    }
    @objc func deleteAction() {
        self.currentValue.text = String(self.currentValue.text?.dropLast() ?? "")
    }
    @objc func doneAction() {
        guard let number = Int(self.currentValue.text ?? "") else {
            return
        }
        self.delegate?.didInputed(number: number)       //동작안함
        self.ad?.paramValue = number
        self.dismiss(animated: true)
    }
}
