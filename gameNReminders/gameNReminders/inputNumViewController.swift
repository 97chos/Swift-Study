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
    lazy var width = 0
    lazy var height = 0
    lazy var margin = self.view.layoutMarginsGuide

    override func viewDidLoad() {

        self.view.backgroundColor = .white

        self.view.addSubview(currentTitle)
        self.view.addSubview(currentValue)
        self.view.addSubview(correctTitle)
        self.view.addSubview(correctRange)

        //MARK:-- Keypad StackView 구문

        let containerRow = stackViewFactory(type: .vertical)
        let row1 = stackViewFactory(type: .horizontal)
        let row2 = stackViewFactory(type: .horizontal)
        let row3 = stackViewFactory(type: .horizontal)
        let row4 = stackViewFactory(type: .horizontal)

        self.view.addSubview(containerRow)
        containerRow.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
        containerRow.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.55).isActive = true
        containerRow.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerRow.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -10).isActive = true

        row1.addArrangedSubview(one)
        row1.addArrangedSubview(two)
        row1.addArrangedSubview(thr)

        row2.addArrangedSubview(four)
        row2.addArrangedSubview(five)
        row2.addArrangedSubview(six)

        row3.addArrangedSubview(sev)
        row3.addArrangedSubview(eig)
        row3.addArrangedSubview(nine)

        row4.addArrangedSubview(delete)
        row4.addArrangedSubview(zero)
        row4.addArrangedSubview(done)

        containerRow.addArrangedSubview(row1)
        containerRow.addArrangedSubview(row2)
        containerRow.addArrangedSubview(row3)
        containerRow.addArrangedSubview(row4)

        row1.widthAnchor.constraint(equalTo: containerRow.widthAnchor).isActive = true
        row1.heightAnchor.constraint(equalTo: containerRow.heightAnchor, multiplier: 0.25, constant: -10).isActive = true
        row1.bottomAnchor.constraint(equalTo: row2.topAnchor, constant: -10).isActive = true

        row2.bottomAnchor.constraint(equalTo: row3.topAnchor, constant: -10).isActive = true
        row2.centerXAnchor.constraint(equalTo: containerRow.centerXAnchor).isActive = true
        row2.widthAnchor.constraint(equalTo: row1.widthAnchor).isActive = true
        row2.heightAnchor.constraint(equalTo: row1.heightAnchor).isActive = true

        row3.bottomAnchor.constraint(equalTo: row4.topAnchor, constant: -10).isActive = true
        row3.centerXAnchor.constraint(equalTo: containerRow.centerXAnchor).isActive = true
        row3.widthAnchor.constraint(equalTo: row2.widthAnchor).isActive = true
        row3.heightAnchor.constraint(equalTo: row2.heightAnchor).isActive = true

        row4.bottomAnchor.constraint(equalTo: containerRow.bottomAnchor, constant: 10).isActive = true
        row4.widthAnchor.constraint(equalTo: row3.widthAnchor).isActive = true
        row4.heightAnchor.constraint(equalTo: row3.heightAnchor).isActive = true

        func stackSubViewsLayout(row: UIStackView) {
            for i in 0...2 {
                row.arrangedSubviews[i].heightAnchor.constraint(equalTo: containerRow.heightAnchor, multiplier: 0.25, constant: -10).isActive = true
            }
        }
        stackSubViewsLayout(row: row1)
        stackSubViewsLayout(row: row2)
        stackSubViewsLayout(row: row3)
        stackSubViewsLayout(row: row4)

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
        currentValue.font = UIFont.boldSystemFont(ofSize: 30)
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
        correctRange.font = UIFont.boldSystemFont(ofSize: 30)
        correctRange.textColor = .black
        correctRange.textAlignment = .center
        correctRange.snp.makeConstraints() {
            $0.top.equalTo(correctTitle.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
    //MARK:-- Keypad Layout
    func stackViewFactory(type: NSLayoutConstraint.Axis) -> UIStackView {
        let row = UIStackView()
        row.alignment = .center
        row.distribution = .fillEqually
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false

        return row
    }

    func oneLayout() {
        one.setTitle("1", for: .normal)
        one.setTitleColor(.systemBlue, for: .normal)
    }
    func twoLayout() {
        two.setTitle("2", for: .normal)
        two.setTitleColor(.systemBlue, for: .normal)
    }
    func thrLayout() {
        thr.setTitle("3", for: .normal)
        thr.setTitleColor(.systemBlue, for: .normal)
    }
    func fourLayout() {
        four.setTitle("4", for: .normal)
        four.setTitleColor(.systemBlue, for: .normal)
    }
    func fiveLayout() {
        five.setTitle("5", for: .normal)
        five.setTitleColor(.systemBlue, for: .normal)
    }
    func sixLayout() {
        six.setTitle("6", for: .normal)
        six.setTitleColor(.systemBlue, for: .normal)
    }
    func sevLayout() {
        sev.setTitle("7", for: .normal)
        sev.setTitleColor(.systemBlue, for: .normal)
    }
    func eigLayout() {
        eig.setTitle("8", for: .normal)
        eig.setTitleColor(.systemBlue, for: .normal)
    }
    func nineLayout() {
        nine.setTitle("9", for: .normal)
        nine.setTitleColor(.systemBlue, for: .normal)
    }
    func deleteLayout() {
        delete.setTitle("Delete", for: .normal)
        delete.setTitleColor(.systemBlue, for: .normal)
    }
    func zeroLayout() {
        zero.setTitle("0", for: .normal)
        zero.setTitleColor(.systemBlue, for: .normal)
    }
    func doneLayout() {
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.systemBlue, for: .normal)
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
            self.dismiss(animated: true)
            return
        }
        //MARK:-- 왜 안돼
        self.delegate?.didInputed(number: number)       //동작안함
        self.ad?.paramValue = number
        let vc = UIViewController() as? NumberGame
        vc?.inputNum.text = String(number)
        print(vc?.inputNum.text)

        self.dismiss(animated: true)

    }
}
