//
//  ViewController.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/18.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var pageView: GXSegmentPageView = {
        var children: [UIViewController] = []
        for i in 0..<4 {
            let vc: OneViewController = OneViewController(number: i)
            children.append(vc)
        }
        var frame = self.view.bounds
        frame.origin.y = 100
        frame.size.height = self.view.bounds.height - 100
        return GXSegmentPageView(frame: frame, parent: self, children: children)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageView.delegate = self
        self.view.addSubview(self.pageView)
    }
    
    @IBAction func leftClicked(_ sender: UIButton) {
        if self.pageView.currentIndex > 0 {
            self.pageView.scrollToItem(to: self.pageView.currentIndex-1, animated: true)
        }
    }
    
    @IBAction func toCenterClicked(_ sender: UIButton) {
        let index: Int = self.pageView.children.count / 2
        self.pageView.scrollToItem(to: index, animated: false)
    }
    
    @IBAction func rightClicked(_ sender: UIButton) {
        if self.pageView.currentIndex < self.pageView.children.count - 1 {
            self.pageView.scrollToItem(to: self.pageView.currentIndex+1, animated: true)
        }
    }
}

extension ViewController: GXSegmentPageViewDelegate {

    func segmentPageView(_ segmentPageView: GXSegmentPageView, progress: CGFloat) {
        NSLog("currentIndex = %d, willIndex = %d, progress = %f", segmentPageView.currentIndex, segmentPageView.willIndex, progress)

    }
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        let vc: OneViewController? = segmentPageView.child(at: index)
        NSLog("at index = %d, numberText = %@", index, vc?.numberLabel.text ?? "")
    }
}

