//
//  GXSegmentView.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/19.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit
@objc protocol GXSegmentTitleViewDelegate: NSObjectProtocol {
    @objc optional func segmentTitleView(_ page: GXSegmentTitleView, at index: Int)
}
class GXSegmentTitleView: UIView {
    public weak var delegate: GXSegmentTitleViewDelegate?
    private let kBeginTag: Int = 1000
    private var config: Configuration!
    private var titles: [String] = []
    private var currentIndex: Int = 0
    
    private var buttons: [UIButton] = []
    private var separators: [UIView] = []
    private var titlesSizes: [CGSize] = []
    private var indicatorFrames: [CGRect] = []
    private var titlesTotalWidth: CGFloat = 0.0
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.frame = self.bounds
        return scrollView
    }()
    
    private lazy var underline: UIView = {
        let line = UIView()
        line.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return line
    }()
    
    private lazy var indicator: UIView = {
        let indicator = UIView()
        indicator.autoresizingMask = [.flexibleTopMargin]
        return indicator
    }()
    
    convenience init(frame: CGRect, config: Configuration, titles: [String]) {
        self.init(frame: frame)
        self.setupSegmentTitleView(config: config, titles: titles)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateContentLayout()
    }
}

extension GXSegmentTitleView {
    /// Xib initializes by calling a function
    func setupSegmentTitleView(config: Configuration, titles: [String]) {
        self.config = config
        self.titles = titles
        self.createSubviews()
        self.selectItem(at: 0)
    }
    func setSegmentTitleView(currentIndex: Int, willIndex: Int, progress: CGFloat) {
        self.scrollTo(currentIndex: currentIndex, willIndex: willIndex, progress: progress)
    }
    func resetConfiguration(config: Configuration) {
        self.config = config
        self.buttons.removeAll()
        self.separators.removeAll()
        self.titlesSizes.removeAll()
        self.updateConfiguration()
    }
    func resetTitles(titles: [String]) {
        self.titles = titles
        self.createSubviews()
    }
}

fileprivate extension GXSegmentTitleView {
    @objc func buttonClicked(_ sender: UIButton) {
        let index = sender.tag - kBeginTag
        self.selectToItem(at: index, animated: true)
        if delegate?.responds(to: #selector(delegate?.segmentTitleView(_:at:))) ?? false {
            self.delegate?.segmentTitleView?(self, at: index)
        }
    }
    func createSubviews() {
        self.subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
        self.currentIndex = 0
        self.buttons.removeAll()
        self.separators.removeAll()
        self.titlesSizes.removeAll()
        
        for (index, title) in self.titles.enumerated() {
            let button: UIButton = UIButton(type: .custom)
            button.tag = index + kBeginTag
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = self.config.titleNormalFont
            button.setTitleColor(self.config.titleNormalColor, for: .normal)
            button.setTitleColor(self.config.titleSelectedColor, for: .selected)
            button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            self.buttons.append(button)
            
            if index > 0 && self.config.isShowSeparator {
                let separator = UIView()
                separator.backgroundColor = self.config.separatorColor
                self.separators.append(separator)
            }
        }
        self.addSubview(self.scrollView)
        if self.config.isShowBottomLine {
            self.addSubview(self.underline)
        }
        if self.config.style != .none {
            self.scrollView.addSubview(self.indicator)
        }
        for button in self.buttons {
            self.scrollView.addSubview(button)
        }
        if self.config.isShowSeparator {
            for separator in self.separators {
                self.scrollView.addSubview(separator)
            }
        }
        self.updateConfiguration()
    }
    /// 更新配置
    func updateConfiguration() {
        self.config.setupGradientColorRGB()
        self.scrollView.bounces = self.config.bounces
        if self.config.isShowBottomLine {
            self.underline.backgroundColor = self.config.bottomLineColor
            var frame = self.bounds
            frame.origin.y = self.bounds.height - self.config.bottomLineHeight
            frame.size.height = self.config.bottomLineHeight
            self.underline.frame = frame
        }
        for title in self.titles {
            let size = self.gx_textSize(title, font: self.config.titleNormalFont)
            self.titlesSizes.append(size)
        }
        self.titlesTotalWidth = 0.0
        for titleSize in self.titlesSizes {
            self.titlesTotalWidth += (titleSize.width + self.config.titleMargin * 2)
        }
        if self.config.style != .none {
            self.indicator.backgroundColor = self.config.indicatorColor
            self.indicator.layer.cornerRadius = self.config.indicatorCornerRadius
            self.indicator.layer.borderWidth = self.config.indicatorBorderWidth
            self.indicator.layer.borderColor = self.config.indicatorBorderColor.cgColor
        }
        for button in self.buttons {
            button.titleLabel?.font = self.config.titleNormalFont
            button.setTitleColor(self.config.titleNormalColor, for: .normal)
            button.setTitleColor(self.config.titleSelectedColor, for: .selected)
        }
        if self.config.isShowSeparator {
            for line in self.separators {
                line.backgroundColor = self.config.separatorColor
            }
        }
        self.updateContentLayout()
    }
    
    /// 更新布局
    func updateContentLayout() {
        self.indicatorFrames.removeAll()
        var left: CGFloat = 0.0
        for (index, button) in self.buttons.enumerated() {
            let btnRect = self.rectForButton(at: index, left: left)
            button.frame = btnRect
            if self.config.isShowSeparator && index > 0 {
                let line = self.separators[index - 1]
                let lineLeft = left - self.config.separatorWidth * 0.5
                let lineTop = self.config.separatorInset.top
                let lineHeight = btnRect.height - lineTop - self.config.separatorInset.bottom
                line.frame = CGRect(x: lineLeft, y: lineTop, width: self.config.separatorWidth, height: lineHeight)
            }
            self.indicatorFrames.append(self.rectIndicator(button: button, at: index))
            left += btnRect.width
        }
        let contentWidth: CGFloat = self.buttons.last?.frame.maxX ?? 0
        self.scrollView.contentSize = CGSize(width: contentWidth, height: self.scrollView.frame.height)
    }
    
    /// 计算获得cell的size
    func rectForButton(at index: Int, left: CGFloat) -> CGRect {
        let height = self.scrollView.frame.height - self.config.bottomLineHeight
        var width: CGFloat = 0.0
        if self.config.titleFixedWidth > 0 {
            // 标题为固定宽度
            width = self.config.titleFixedWidth
        }
        else {
            // 标题为动态宽度,小于一屏配titleMargin补上
            var titleMargin = self.config.titleMargin * 2
            if self.titlesTotalWidth < self.scrollView.frame.width {
                let differenceW = self.scrollView.frame.width - self.titlesTotalWidth
                titleMargin +=  differenceW / CGFloat(self.titles.count)
            }
            width = self.titlesSizes[index].width + titleMargin
        }
        return CGRect(x: left, y: 0, width: width, height: height)
    }
    /// 获取指示器位置
    func rectIndicator(button: UIButton, at index: Int) -> CGRect {
        let titleSize = self.titlesSizes[index]
        var width = self.config.indicatorFixedWidth
        if width == 0 {
            width = titleSize.width + self.config.indicatorAdditionWidthMargin * 2
        }
        var height = self.config.indicatorFixedHeight
        if height == 0 {
            height = titleSize.height + self.config.indicatorAdditionHeightMargin * 2
        }
        let left = button.frame.origin.x + (button.frame.width - width) * 0.5
        
        var top: CGFloat = 0.0
        switch self.config.style {
        case .top:
            top = self.config.indicatorMargin
        case .center:
            top = (button.frame.height - height) * 0.5
        case .bottom:
            top = button.frame.height - self.config.indicatorMargin - height
        default: break
        }
        return CGRect(x: left, y: top, width: width, height: height)
    }
    
    /// 滚动到选项
    func scrollToItem(at index: Int, animated: Bool)  {
        let button = self.buttons[index]
        let left = button.center.x - self.scrollView.frame.width * 0.5
        let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
        self.scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    /// 选择到项目
    func selectToItem(at index: Int, animated: Bool)  {
        guard self.currentIndex != index else {return}
        
        for (idx, button) in self.buttons.enumerated() {
            if idx == index || idx == self.currentIndex { continue }
            button.isSelected = false
            button.titleLabel?.font = self.config.titleNormalFont
            button.titleLabel?.textColor = self.config.titleNormalColor
        }
        let currButton: UIButton = self.buttons[self.currentIndex]
        let willButton: UIButton = self.buttons[index]
        currButton.isSelected = false
        willButton.isSelected = true
        self.currentIndex = index

        let frame = self.indicatorFrames[index]
        let scale = self.config.titleSelectedFontScale
        if animated && self.config.isIndicatorAnimation {
            UIView.animate(withDuration: self.config.indicatorDuration) {
                self.indicator.frame = frame
                if self.config.isTitleZoom {
                    currButton.transform = .identity
                    willButton.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
                else {
                    currButton.titleLabel?.font = self.config.titleNormalFont
                    willButton.titleLabel?.font = self.config.titleSelectedFont
                }
                currButton.titleLabel?.textColor = self.config.titleNormalColor
                willButton.titleLabel?.textColor = self.config.titleSelectedColor
            }
        }
        else {
            self.indicator.frame = frame
            if self.config.isTitleZoom {
                currButton.transform = .identity
                willButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            else {
                currButton.titleLabel?.font = self.config.titleNormalFont
                willButton.titleLabel?.font = self.config.titleSelectedFont
            }
            currButton.titleLabel?.textColor = self.config.titleNormalColor
            willButton.titleLabel?.textColor = self.config.titleSelectedColor
        }
        self.scrollToItem(at: index, animated: animated)
    }
    
    /// 直接选中项目
    func selectItem(at index: Int) {
        for (idx, button) in self.buttons.enumerated() {
            if idx == index {
                button.isSelected = true
                if self.config.isTitleZoom {
                    let scale = self.config.titleSelectedFontScale
                    button.transform = CGAffineTransform(scaleX: scale, y: scale)
                } else {
                    button.titleLabel?.font = self.config.titleSelectedFont
                }
                button.titleLabel?.textColor = self.config.titleSelectedColor
            }
            else {
                button.isSelected = false
                if self.config.isTitleZoom {
                    button.transform = .identity
                } else {
                    button.titleLabel?.font = self.config.titleNormalFont
                }
                button.titleLabel?.textColor = self.config.titleNormalColor
            }
        }
        self.indicator.frame = self.indicatorFrames[index]
        self.currentIndex = index
    }
    
    /// 联动函数
    func scrollTo(currentIndex: Int, willIndex: Int, progress: CGFloat) {
        let currButton: UIButton = self.buttons[currentIndex]
        let willButton: UIButton = self.buttons[willIndex]
//
//        if progress >= 0.9 {
//            let left = willButton.center.x - self.scrollView.frame.width * 0.5
//            let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
//            self.scrollView.scrollRectToVisible(rect, animated: true)
//        }
//        else {
//            let left = currButton.center.x - self.scrollView.frame.width * 0.5
//            let rect = CGRect(origin: CGPoint(x: left, y: 0), size: self.scrollView.frame.size)
//            self.scrollView.scrollRectToVisible(rect, animated: true)
//        }

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
        if self.config.isTitleZoom {
            let willScale = self.config.changeFontScale(progress: progress, isWillSelected: true)
            willButton.transform = CGAffineTransform(scaleX: willScale, y: willScale)
            let currScale = self.config.changeFontScale(progress: progress, isWillSelected: false)
            currButton.transform = CGAffineTransform(scaleX: currScale, y: currScale)
        }
        if self.config.isTitleColorGradient {
            let willColor = self.config.changeColor(progress: progress, isWillSelected: true)
            willButton.titleLabel?.textColor = willColor
            let currColor = self.config.changeColor(progress: progress, isWillSelected: false)
            currButton.titleLabel?.textColor = currColor
        }

        if progress >= 1.0 {
            self.selectItem(at: willIndex)
            self.scrollToItem(at: willIndex, animated: true)
        }
        else if progress <= 0.0 {
            self.selectItem(at: currentIndex)
            self.scrollToItem(at: currentIndex, animated: true)
        }
    }
}
