//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/11/25.
//

import UIKit

class MemoFormVC: UIViewController {

    var subject: String!
    lazy var dao = MemoDAO()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contents.delegate = self

        // 배경 이미지 설정
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage)

        // 텍스트 뷰 기본 속성
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = UIColor.clear

        // 줄 간격
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        self.contents.attributedText = NSAttributedString(string: "",
                                                          attributes: [.paragraphStyle: style])
        self.contents.text = ""

    }

    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!

    @IBAction func save(_ sender: Any) {
        // 경고창에 사용될 콘텐츠 뷰 컨트롤러 구성
        let alertV = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        let iconImageV = UIImageView(image: iconImage)
        iconImageV.frame = CGRect(x: 0, y: 0, width: (iconImage?.size.width)!, height: (iconImage?.size.height)!)
        alertV.view.addSubview(iconImageV)
        alertV.preferredContentSize = CGSize(width: iconImageV.frame.size.width, height: iconImageV.frame.size.height + 10)

        guard self.contents.text.isEmpty == false else {
            let alert = UIAlertController(title: nil,
                                          message: "내용을 입력해주세요",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.setValue(alertV, forKey: "contentViewController")
            self.present(alert, animated: true)
            return
        }

        let data = MemoData()
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date()

        // 코어 데이터에 메모 데이터 추가
        self.dao.insert(data)

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func pick(_ sender: Any) {

        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        self.present(picker, animated: true)
    }

    // 뷰 터치 시 네비게이션 바 숨기기
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar

        let tf = TimeInterval(0.3)
        UIView.animate(withDuration: tf) {
            bar?.alpha = (bar?.alpha == 0 ? 1 : 0)
        }
    }
}

extension MemoFormVC: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.preview.image = info[.editedImage] as? UIImage

        picker.dismiss(animated: true)
    }

}

extension MemoFormVC: UINavigationControllerDelegate {

}

extension MemoFormVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = contents.length > 15 ? 15 : contents.length
        self.subject = contents.substring(with: NSRange(location: 0, length: length))

        self.navigationItem.title = self.subject
    }
}
