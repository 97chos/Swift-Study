//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by sangho Cho on 2020/12/04.
//

import Foundation
import UIKit

class TutorialMasterVC: UIViewController {
    var pageVC: UIPageViewController!

    // 콘텐츠 뷰 컨트롤러에 들어갈 타이틀과 이미지
    var contentTitles = ["Step 1","Step 2","Step 3","Step 4"]
    var contentImages = ["Page 0","Page 1","Page 2","Page 3"]

    @IBAction func close(_ sender: UIButton) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()

        self.presentingViewController?.dismiss(animated: true)
    }

    // 입력받은 인덱스 값에 해당하는 콘텐츠 뷰 컨트롤러의 인스턴스를 생성하여 반환하는 커스텀 메소드
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        // 인덱스가 데이터 배열 크기 범위를 벗어나면 nil 반환
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }

        // "ContentsVC"라는 Storyboard ID를 가진 뷰 컨트롤러의 인스턴스를 생성하고 캐스팅
        guard let cvc = self.instanceTutorialVC(name: "contentsVC") as? TutorialContentsVC else {
            return nil
        }

        // 콘텐츠 뷰 컨트롤러의 내용 구성
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx

        return cvc
    }

    override func viewDidLoad() {

        // 1. 페이지 뷰 컨트롤러 객체 생성
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self

        // 2. 페이지 뷰 컨트롤러 기본 페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)!     // 최초 노출될 콘텐츠 뷰 컨트롤러
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)

        // 3. 페이지 뷰 컨트롤러의 출력 영역 지정
        self.pageVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 100)

        // 4. 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 지정
        self.addChild(pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)
    }

    // 페이지 뷰 컨트롤러가 출력할 페이지의 갯수를 알려주는 역할
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }

    // 페이지 뷰 컨트롤러가 최초에 출력할 콘텐츠 뷰의 인덱스 번호를 알려주는 역할
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension TutorialMasterVC: UIPageViewControllerDataSource {

    // 현재의 콘텐츠 뷰 컨트롤러보다 앞쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 앞쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        // 현재 페이지의 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }

        // 현재 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else {
            return nil
        }

        index -= 1      // 현재 인덱스 - 1, 즉, 이전 페이지의 인덱스
        return self.getContentVC(atIndex: index)
    }

    // 현재 콘텐츠 뷰 컨트롤러보다 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 뒤쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }

        index += 1      // 현재 인덱스 + 1, 즉, 다음 페이지의 인덱스

        // 인덱스는 항상 배열 데이터의 크기보다 작아야 한다.
        guard index < self.contentTitles.count else {
            return nil
        }

        return self.getContentVC(atIndex: index)
    }
}
