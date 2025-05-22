//
//  GXSegmentView+Configuration.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/21.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public extension GXSegmentTitleView {
    /// 风格
    @objc enum PositionStyle : Int {
        /// 没有指示器
        case none   = 0
        /// 居上
        case top    = 1
        /// 居中
        case center = 2
        /// 底部
        case bottom = 3
    }
    /// 指示器滚动风格
    @objc enum IndicatorStyle : Int {
        /// 指示器位置需内容滚动结束时改变
        case none    = 0
        /// 指示器位置需内容滚动一半时改变
        case half    = 1
        /// 指示器位置跟随内容滚动
        case follow  = 2
        /// 指示器位置跟随内容动态滚动
        case dynamic = 3
    }
    
    @objc class Configuration: NSObject {
        // MARK: - GXSegmentView配置
        
        /// 位置风格
        @objc public var positionStyle: PositionStyle = .bottom
        /// 弹性效果
        @objc public var bounces: Bool = true
        /// 是否显示底部线条
        @objc public var isShowBottomLine: Bool = true
        /// 底部线条颜色
        @objc public var bottomLineColor: UIColor = .lightGray
        /// 底部线条高度
        @objc public var bottomLineHeight: CGFloat = 0.5
        /// 是否显示Item分割线
        @objc public var isShowSeparator: Bool = false
        /// 分割线颜色
        @objc public var separatorColor: UIColor = .orange
        /// 分割线inset(top/bottom有效)
        @objc public var separatorInset: UIEdgeInsets = .zero
        /// 分割线宽度
        @objc public var separatorWidth: CGFloat = 1.0
        
        // MARK: - title属性配置
        
        /// 正常标题字体
        @objc public var titleNormalFont: UIFont = .systemFont(ofSize: 15)
        /// 选中标题字体(不能和titleSelectedFontSize一起使用)
        @objc public var titleSelectedFont: UIFont = .boldSystemFont(ofSize: 15)
        /// 正常标题颜色
        @objc public var titleNormalColor: UIColor = .black
        /// 选中标题颜色
        @objc public var titleSelectedColor: UIColor = .orange
        /// 是否有颜色梯度渐变效果
        @objc public var isTitleColorGradient: Bool = true
        /// 是否让标题文字具有缩放效果
        @objc public var isTitleZoom: Bool = true
        /// 标题选中时的缩放比例（自己根据实际情况调整）
        @objc public var titleSelectedFontScale: CGFloat = 1.2
        /// 标题的边距
        @objc public var titleMargin: CGFloat = 20.0
        /// 标题的固定宽度（默认0为动态宽度，大于0则设置为固定宽度）
        @objc public var titleFixedWidth: CGFloat = 0.0
        /// 开启内容不满屏的情况下标题是否均匀分布
        @objc public var isNoFullAverage: Bool = true
        /// 开启内容不满屏的情况下指示器是否均匀分布
        @objc public var isNoFullAverageAndIndicator: Bool = false
        
        //MARK: - 指示器属性
        
        /// 指示器滚动风格
        @objc public var indicatorStyle: IndicatorStyle = .dynamic
        /// 指示器颜色
        @objc public var indicatorColor: UIColor = .orange
        /// 指示器的滚动动画持续时间
        @objc public var indicatorDuration: TimeInterval = 0.1
        /// 指示器圆角大小
        @objc public var indicatorCornerRadius: CGFloat = 1.0
        /// 指示器边框宽度
        @objc public var indicatorBorderWidth: CGFloat = 0.0
        /// 指示器边框颜色
        @objc public var indicatorBorderColor: UIColor = .clear
        /// 指示器的底部或者顶部边距（top/bottom风格有效）
        @objc public var indicatorMargin: CGFloat = 0.5
        
        /// 指示器固定宽度（默认0为动态跟标题一致的宽度，大于0则设置为固定宽度）
        @objc public var indicatorFixedWidth: CGFloat = 0
        /// 指示器固定高度（默认0为动态跟标题一致的高度，大于0则设置为固定高度）
        @objc public var indicatorFixedHeight: CGFloat = 2.0
        /// 指示器添加的宽度边距（indicatorFixedWidth>0时不启用）
        @objc public var indicatorAdditionWidthMargin: CGFloat = 0
        /// 指示器添加的高度边距（indicatorFixedHeight>0时不启用）
        @objc public var indicatorAdditionHeightMargin: CGFloat = 0
        
        private(set) var normalRGB: [CGFloat] = Array(repeating: 0, count: 4)
        private(set) var selectRGB: [CGFloat] = Array(repeating: 0, count: 4)
        
        func setupGradientColorRGB() {
            self.normalRGB[0] = self.titleNormalColor.cgColor.components.red
            self.normalRGB[1] = self.titleNormalColor.cgColor.components.green
            self.normalRGB[2] = self.titleNormalColor.cgColor.components.blue
            self.normalRGB[3] = self.titleNormalColor.cgColor.components.alpha
            
            self.selectRGB[0] = self.titleSelectedColor.cgColor.components.red
            self.selectRGB[1] = self.titleSelectedColor.cgColor.components.green
            self.selectRGB[2] = self.titleSelectedColor.cgColor.components.blue
            self.selectRGB[3] = self.titleSelectedColor.cgColor.components.alpha
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
        
        func changeFontScale(progress: CGFloat, isWillSelected: Bool) -> CGFloat {
            let difference = self.titleSelectedFontScale - 1.0
            if isWillSelected {
                return 1.0 + difference * progress
            } else {
                return self.titleSelectedFontScale - difference * progress
            }
        }
    }
    
    @objc func gx_textSize(_ text: String, font: UIFont) -> CGSize {
        let attributes: [NSAttributedString.Key : Any] = [.font: font]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,.usesFontLeading]
        return attrString.boundingRect(with: .zero, options: options, context: nil).size
    }
}

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif
public extension CGColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        #if os(iOS)
            UIColor(cgColor: self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif os(OSX)
            NSColor(cgColor: self)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return (r, g, b, a)
    }
}
