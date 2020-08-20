//
//  GXSegmentView.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/19.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
@objc protocol GXSegmentViewDelegate: NSObjectProtocol {
    @objc optional func segmentView(_ page: GXSegmentView, at index: Int)
}
class GXSegmentView: UIView {
    public weak var delegate: GXSegmentViewDelegate?
    private let kBeginTag: Int = 1000
    private var config: Configuration!
    private var titles: [String] = []
    private var normalRGB: [CGFloat] = Array(repeating: 0, count: 4)
    private var selectRGB: [CGFloat] = Array(repeating: 0, count: 4)
    private var currentIndex: Int = 0
    private var willIndex: Int = 0

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = self.config.bounces
        scrollView.frame = self.bounds
        return scrollView
    }()
    
    private lazy var bottomLine: UIView = {
        let line = UIView()
        line.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        line.backgroundColor = self.config.bottomLineColor
        var frame = self.bounds
        frame.origin.y = self.bounds.height - self.config.bottomLineHeight
        frame.size.height = self.config.bottomLineHeight
        line.frame = frame
        return line
    }()
    
    private lazy var indicator: UIView = {
        let indicator = UIView()
        indicator.autoresizingMask = [.flexibleTopMargin]
        indicator.backgroundColor = self.config.indicatorColor
        indicator.layer.cornerRadius = self.config.indicatorCornerRadius
        indicator.layer.borderWidth = self.config.indicatorBorderWidth
        indicator.layer.borderColor = self.config.indicatorBorderColor.cgColor
        return indicator
    }()
    
    private lazy var buttons: [UIButton] = {
        var buttonArr: [UIButton] = []
        for (index, title) in self.titles.enumerated() {
            let button: UIButton = UIButton(type: .custom)
            button.tag = index + kBeginTag
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = self.config.titleNormalFont
            button.setTitleColor(self.config.titleNormalColor, for: .normal)
            button.setTitleColor(self.config.titleSelectedColor, for: .selected)
            button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            buttonArr.append(button)
        }
        return buttonArr
    }()
    
    private lazy var separators: [UIView] = {
        var separators: [UIView] = []
        for (index, title) in self.titles.enumerated() {
            guard index > 0 else {continue}
            let line = UIView()
            line.backgroundColor = self.config.separatorColor
            separators.append(line)
        }
        return separators
    }()
    
    private lazy var titlesSizes: [CGSize] = {
        var sizes: [CGSize] = []
        for title in self.titles {
            let size = self.gx_textSize(text: title, font: self.config.titleNormalFont)
            sizes.append(size)
        }
        return sizes
    }()
    
    private lazy var indicatorFrames: [CGRect] = {
        return []
    }()
    
    convenience init(frame: CGRect, config: Configuration, titles: [String]) {
        self.init(frame: frame)
        self.setupSegmentView(config: config, titles: titles)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateContentLayout()
    }
}

extension GXSegmentView {
    /// Xib initializes by calling a function
    func setupSegmentView(config: Configuration, titles: [String]) {
        self.config = config
        self.titles = titles
        self.setupGradientColorRGB()
        self.setupSubviews()
    }
    func setSegmentView(currentIndex: Int, willIndex: Int, progress: CGFloat) {
        self.scrollTo(currentIndex: currentIndex, willIndex: willIndex, progress: progress)
    }
}

fileprivate extension GXSegmentView {
    @objc func buttonClicked(_ sender: UIButton) {
        let index = sender.tag - kBeginTag
        self.scrollToIndex(at: index, animated: true)
        if delegate?.responds(to: #selector(delegate?.segmentView(_:at:))) ?? false {
            self.delegate?.segmentView?(self, at: index)
        }
    }
    func setupSubviews() {
        self.addSubview(self.scrollView)
        if self.config.isShowBottomLine {
            self.addSubview(self.bottomLine)
        }
        if self.config.style != .none {
            self.scrollView.addSubview(self.indicator)
        }
        for button in self.buttons {
            self.scrollView.addSubview(button)
        }
        if self.config.isShowSeparator {
            for line in self.separators {
                self.scrollView.addSubview(line)
            }
        }
        self.updateContentLayout()
    }
    func setupGradientColorRGB() {
        self.normalRGB[0] = config.titleNormalColor.cgColor.components.red
        self.normalRGB[1] = config.titleNormalColor.cgColor.components.green
        self.normalRGB[2] = config.titleNormalColor.cgColor.components.blue
        self.normalRGB[3] = config.titleNormalColor.cgColor.components.alpha
        
        self.selectRGB[0] = config.titleSelectedColor.cgColor.components.red
        self.selectRGB[1] = config.titleSelectedColor.cgColor.components.green
        self.selectRGB[2] = config.titleSelectedColor.cgColor.components.blue
        self.selectRGB[3] = config.titleSelectedColor.cgColor.components.alpha
    }
    func changeColor(progress: CGFloat, isWillSelected: Bool) -> UIColor {
        let beginRGB: [CGFloat] = isWillSelected ? self.normalRGB : self.selectRGB
        let endRGB: [CGFloat]   = isWillSelected ? self.selectRGB : self.normalRGB
        
        let r = (endRGB[0] - beginRGB[0]) * progress + beginRGB[0]
        let g = (endRGB[1] - beginRGB[1]) * progress + beginRGB[1]
        let b = (endRGB[2] - beginRGB[2]) * progress + beginRGB[2]
        let a = (endRGB[3] - beginRGB[3]) * progress + beginRGB[3]
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func changeScale(progress: CGFloat, isWillSelected: Bool) -> CGFloat {
        let differenceScale = self.config.titleSelectedScale - 1.0
        if isWillSelected {
            return 1.0 + differenceScale * progress
        }
        else {
            return self.config.titleSelectedScale - differenceScale * progress
        }
    }
    func updateContentLayout() {
        self.indicatorFrames.removeAll()
        let height = self.scrollView.frame.height - self.config.bottomLineHeight
        /// 标题为固定宽度
        if self.config.titleFixedWidth > 0 {
            for (index, button) in self.buttons.enumerated() {
                let width = self.config.titleFixedWidth
                let left = CGFloat(index) * width
                button.frame = CGRect(x: left, y: 0, width: width, height: height)
                self.indicatorFrames.append(self.indicatorFrame(index: index, button: button))
                
                if self.config.isShowSeparator && index > 0 {
                    let line = self.separators[index - 1]
                    let lineLeft = left - self.config.separatorWidth * 0.5
                    let lineTop = self.config.separatorInset.top
                    let lineHeight = height - lineTop - self.config.separatorInset.bottom
                    line.frame = CGRect(x: lineLeft, y: lineTop, width: self.config.separatorWidth, height: lineHeight)
                }
            }
        }
        /// 标题为动态宽度
        else {
            // 计算文本总宽度
            var titlesTotalWidth: CGFloat = 0.0
            for titleSize in self.titlesSizes {
                titlesTotalWidth += (titleSize.width + self.config.titleMargin * 2)
            }
            // 小于一屏配titleMargin补上
            var titleMargin = self.config.titleMargin
            if titlesTotalWidth < self.scrollView.frame.width {
                titleMargin += (self.scrollView.frame.width-titlesTotalWidth)/CGFloat(self.titles.count)*0.5
            }
            var left: CGFloat = 0.0
            for (index, button) in self.buttons.enumerated() {
                let width = self.titlesSizes[index].width + titleMargin * 2
                button.frame = CGRect(x: left, y: 0, width: width, height: height)
                
                if self.config.isShowSeparator && index > 0 {
                    let line = self.separators[index - 1]
                    let lineLeft = left - self.config.separatorWidth * 0.5
                    let lineTop = self.config.separatorInset.top
                    let lineHeight = height - lineTop - self.config.separatorInset.bottom
                    line.frame = CGRect(x: lineLeft, y: lineTop, width: self.config.separatorWidth, height: lineHeight)
                }
                self.indicatorFrames.append(self.indicatorFrame(index: index, button: button))
                left += width
            }
        }
        let contentWidth: CGFloat = self.buttons.last?.frame.maxX ?? 0
        self.scrollView.contentSize = CGSize(width: contentWidth, height: self.scrollView.frame.height)
        self.scrollToIndex(at: self.currentIndex, animated: false)
    }
    func indicatorFrame(index: Int, button: UIButton) -> CGRect {
        if self.config.style == .line {
            var left: CGFloat = button.frame.origin.x, width: CGFloat = 0.0
            let height: CGFloat = self.config.indicatorHeight
            let top: CGFloat = button.frame.height - height - self.config.indicatorBottomMargin
            if self.config.indicatorInset == .zero {
                if self.config.indicatorFixedWidth > 0 {
                    width = self.config.indicatorFixedWidth
                }
                else {
                    width = self.titlesSizes[index].width + self.config.indicatorAdditionMarginWidth * 2
                }
                left += (button.frame.width - width)/2
            }
            else {
                left += self.config.indicatorInset.left
                width = button.frame.width - (self.config.indicatorInset.left + self.config.indicatorInset.right)
            }
            return CGRect(x: left, y: top, width: width, height: height)
        }
        else if self.config.style == .cover {
            var left: CGFloat = button.frame.origin.x, top: CGFloat = button.frame.origin.y
            var width: CGFloat = 0.0, height: CGFloat = 0.0
            if self.config.indicatorInset == .zero {
                width = self.titlesSizes[index].width + self.config.indicatorAdditionMarginWidth * 2
                height = self.titlesSizes[index].height + self.config.indicatorAdditionMarginHeight * 2
                left += (button.frame.width - width)/2
                top += (button.frame.height - height)/2
            }
            else {
                left += self.config.indicatorInset.left
                top += self.config.indicatorInset.top
                width = button.frame.width - (self.config.indicatorInset.left + self.config.indicatorInset.right)
                height = button.frame.height - (self.config.indicatorInset.top + self.config.indicatorInset.bottom)
            }
            return CGRect(x: left, y: top, width: width, height: height)
        }
        return .zero
    }
    func scrollToIndex(at index: Int, animated: Bool) {
        let originalButton: UIButton = self.buttons[self.currentIndex]
        originalButton.isSelected = false
        let currentButton: UIButton = self.buttons[index]
        currentButton.isSelected = true
        let left = currentButton.center.x - self.scrollView.frame.width * 0.5
        let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
        self.scrollView.scrollRectToVisible(rect, animated: animated)
        self.currentIndex = index
        
        let frame = self.indicatorFrames[index]
        if self.config.isIndicatorAnimation {
            let frame = self.indicatorFrames[index]
            let scale = self.config.titleSelectedScale
            UIView.animate(withDuration: self.config.indicatorDuration) {
                self.indicator.frame = frame
                if self.config.isTitleScale {
                    originalButton.transform = .identity
                    currentButton.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            if !self.config.isTitleScale {
                originalButton.titleLabel?.font = self.config.titleNormalFont
                currentButton.titleLabel?.font = self.config.titleSelectedFont
            }
        }
        else {
            self.indicator.frame = frame
            if self.config.isTitleScale {
                let scale = self.config.titleSelectedScale
                originalButton.transform = .identity
                currentButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            else {
                originalButton.titleLabel?.font = self.config.titleNormalFont
                currentButton.titleLabel?.font = self.config.titleSelectedFont
            }
        }
    }
    func updateButton(at index: Int, isSelected: Bool) {
        let button: UIButton = self.buttons[index]
        button.isSelected = isSelected
        if isSelected {
            if self.config.isTitleScale {
                let scale = self.config.titleSelectedScale
                button.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                button.titleLabel?.font = self.config.titleSelectedFont
            }
            button.titleLabel?.textColor = self.config.titleSelectedColor
        }
        else {
            if self.config.isTitleScale {
                button.transform = .identity
            } else {
                button.titleLabel?.font = self.config.titleNormalFont
            }
            button.titleLabel?.textColor = self.config.titleNormalColor
        }
    }
    func scrollTo(currentIndex: Int, willIndex: Int, progress: CGFloat) {
        let currButton: UIButton = self.buttons[currentIndex]
        let willButton: UIButton = self.buttons[willIndex]
        
        if progress >= 0.5 {
            let left = willButton.center.x - self.scrollView.frame.width * 0.5
            let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
            self.scrollView.scrollRectToVisible(rect, animated: true)
        }
        else {
            let left = currButton.center.x - self.scrollView.frame.width * 0.5
            let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
            self.scrollView.scrollRectToVisible(rect, animated: true)
        }

        if self.config.indicatorStyle == .none {
            if progress >= 1.0 {
                let frame = self.indicatorFrames[willIndex]
                UIView.animate(withDuration: self.config.indicatorDuration) {
                    self.indicator.frame = frame
                }
            }
            else {
                let frame = self.indicatorFrames[currentIndex]
                UIView.animate(withDuration: self.config.indicatorDuration) {
                    self.indicator.frame = frame
                }
            }
        }
        else if self.config.indicatorStyle == .half {
            if progress >= 0.5 {
                let frame = self.indicatorFrames[willIndex]
                UIView.animate(withDuration: self.config.indicatorDuration) {
                    self.indicator.frame = frame
                }
            }
            else {
                let frame = self.indicatorFrames[currentIndex]
                UIView.animate(withDuration: self.config.indicatorDuration) {
                    self.indicator.frame = frame
                }
            }
        }
        else if self.config.indicatorStyle == .follow {
            let currFrame = self.indicatorFrames[currentIndex]
            let willFrame = self.indicatorFrames[willIndex]
            let differenceW = willFrame.width - currFrame.width
            let differenceX = willFrame.origin.x - currFrame.origin.x
            let left = currFrame.origin.x + differenceX * progress
            let width = currFrame.width + differenceW * progress
            let frame = CGRect(x: left, y: currFrame.origin.y, width: width, height: currFrame.height)
            self.indicator.frame = frame
        }
        else if self.config.indicatorStyle == .dynamic {
            let currFrame = self.indicatorFrames[currentIndex]
            let willFrame = self.indicatorFrames[willIndex]
            // 往左滑动
            if currentIndex < willIndex {
                if progress <= 0.5 {
                    let differenceX = currFrame.width * 0.5
                    let left = currFrame.origin.x + differenceX * progress * 2
                    let centerW = willFrame.midX - currFrame.midX
                    let differenceW = centerW - currFrame.width
                    let width = currFrame.width + differenceW * progress * 2
                    let frame = CGRect(x: left, y: currFrame.origin.y, width: width, height: currFrame.height)
                    self.indicator.frame = frame
                }
                else {
                    let differenceX = willFrame.origin.x - currFrame.midX
                    let left = willFrame.origin.x - differenceX * (1.0 - progress) * 2
                    let centerW = willFrame.midX - currFrame.midX
                    let differenceW = willFrame.width - centerW
                    let width = willFrame.width + (progress - 1.0) * differenceW * 2
                    let frame = CGRect(x: left, y: currFrame.origin.y, width: width, height: currFrame.height)
                    self.indicator.frame = frame
                }
            }
            // 往右滑动
            else {
                if progress <= 0.5 {
                    let differenceX = currFrame.origin.x - willFrame.midX
                    let left = currFrame.origin.x - differenceX * progress * 2
                    let centerW = currFrame.midX - willFrame.midX
                    let differenceW = centerW - currFrame.width
                    let width = currFrame.width + differenceW * progress * 2
                    let frame = CGRect(x: left, y: currFrame.origin.y, width: width, height: currFrame.height)
                    self.indicator.frame = frame
                }
                else {
                    let differenceX = willFrame.width * 0.5
                    let left = willFrame.origin.x + differenceX * (1.0 - progress) * 2
                    let centerW = currFrame.midX - willFrame.midX
                    let differenceW = centerW - willFrame.width
                    let width = willFrame.width + differenceW * (1.0 - progress) * 2
                    let frame = CGRect(x: left, y: currFrame.origin.y, width: width, height: currFrame.height)
                    self.indicator.frame = frame
                }
            }
        }
        if self.config.isTitleScale {
            let willScale = self.changeScale(progress: progress, isWillSelected: true)
            willButton.transform = CGAffineTransform(scaleX: willScale, y: willScale)
            let currScale = self.changeScale(progress: progress, isWillSelected: false)
            currButton.transform = CGAffineTransform(scaleX: currScale, y: currScale)
        }
        if self.config.isTitleColorGradient {
            let willColor = self.changeColor(progress: progress, isWillSelected: true)
            willButton.titleLabel?.textColor = willColor
            let currColor = self.changeColor(progress: progress, isWillSelected: false)
            currButton.titleLabel?.textColor = currColor
        }
        
        if progress >= 1.0 {
            self.updateButton(at: willIndex, isSelected: true)
            self.updateButton(at: currentIndex, isSelected: false)
            self.currentIndex = willIndex
        }
        else if progress <= 0.0 {
            self.updateButton(at: willIndex, isSelected: false)
            self.updateButton(at: currentIndex, isSelected: true)
            self.currentIndex = currentIndex
        }
    }
}
