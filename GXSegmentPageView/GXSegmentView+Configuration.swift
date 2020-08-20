//
//  GXSegmentView+Configuration.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/19.
//  Copyright © 2020 gin. All rights reserved.
//
import UIKit

extension GXSegmentView {
    /// 风格
    enum Style : Int {
        /// 没有指示器
        case none  = 0
        /// 下划线格式
        case line  = 1
        /// 遮盖格式
        case cover = 2
    }
    /// 指示器滚动风格
    enum IndicatorStyle : Int {
        /// 指示器位置需内容滚动结束时改变
        case none    = 0
        /// 指示器位置需内容滚动一半时改变
        case half    = 1
        /// 指示器位置跟随内容滚动
        case follow  = 2
        /// 指示器位置跟随内容动态滚动
        case dynamic = 3
    }
    
    struct Configuration {
        // MARK: - GXSegmentView配置
        
        /// 风格
        var style: Style = .line
        /// 弹性效果
        var bounces: Bool = true
        /// 是否显示底部线条
        var isShowBottomLine: Bool = true
        /// 底部线条颜色
        var bottomLineColor: UIColor = .lightGray
        /// 底部线条高度
        var bottomLineHeight: CGFloat = 0.5
        /// 是否显示Item分割线
        var isShowSeparator: Bool = false
        /// 分割线颜色
        var separatorColor: UIColor = .orange
        /// 分割线inset(top/bottom有效)
        var separatorInset: UIEdgeInsets = .zero
        /// 分割线宽度
        var separatorWidth: CGFloat = 1.0
        
        // MARK: - title属性配置
        
        /// 正常标题字体
        var titleNormalFont: UIFont = .systemFont(ofSize: 15)
        /// 选中标题字体(不能和titleSelectedScale一起使用)
        var titleSelectedFont: UIFont = .boldSystemFont(ofSize: 15)
        /// 正常标题颜色
        var titleNormalColor: UIColor = .black
        /// 选中标题颜色
        var titleSelectedColor: UIColor = .orange
        /// 是否有颜色梯度渐变效果
        var isTitleColorGradient: Bool = true
        /// 是否让标题文字具有缩放效果
        var isTitleScale: Bool = true
        /// 标题选中时的缩放比例（自己根据实际情况调整）
        var titleSelectedScale: CGFloat = 1.2
        /// 标题的边距
        var titleMargin: CGFloat = 20.0
        /// 标题的固定宽度（默认0为动态宽度，大于0则设置为固定宽度）
        var titleFixedWidth: CGFloat = 0.0
        
        //MARK: - 指示器属性
        
        /// 指示器滚动风格
        var indicatorStyle: IndicatorStyle = .dynamic
        /// 指示器的底部边距
        var indicatorBottomMargin: CGFloat = 0.5
        /// 指示器颜色
        var indicatorColor: UIColor = .orange
        /// 指示器是否有滚动动画
        var isIndicatorAnimation: Bool = true
        /// 指示器的滚动动画持续时间
        var indicatorDuration: TimeInterval = 0.1
        /// 指示器圆角大小
        var indicatorCornerRadius: CGFloat = 1.0
        /// 指示器边框宽度
        var indicatorBorderWidth: CGFloat = 0.0
        /// 指示器边框颜色
        var indicatorBorderColor: UIColor = .clear
        
        /**
         备注说明：
         1.line风格下indicatorFixedWidth为0默认为文本宽度，大于0则为固定宽度，top/bottom不启用
         2.line风格下indicatorInset为zero默认为indicatorFixedWidth的设置，不为zero则为Item的宽度
         3.line风格下indicatorAdditionMarginWidth可用
         4.cover风格下indicatorInset为zero默认为文本宽高，不为zero则为Item的宽高
         5.cover风格下indicatorAdditionMarginWidth|indicatorAdditionMarginHeight均可用
         6.indicatorInset不为zero，则后续设置宽高部分均无效
         */
        
        /// 指示器高度（* 仅line风格下有效）
        var indicatorHeight: CGFloat = 2.0
        /// 指示器的inset（line风格初始为item的宽、cover为item宽高，非zero时，下列属性不启用）
        var indicatorInset: UIEdgeInsets = .zero
        /// 指示器固定宽度（* 仅line风格下有效，默认0为动态跟标题一致的宽度，大于0则设置为固定宽度）
        var indicatorFixedWidth: CGFloat = 0
        /// 指示器添加的宽度（indicatorFixedWidth>0时不启用）
        var indicatorAdditionMarginWidth: CGFloat = 0
        /// 指示器添加的高度（* 仅cover下有效）
        var indicatorAdditionMarginHeight: CGFloat = 0
    }
    
    func gx_textSize(text: String, font: UIFont) -> CGSize {
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
extension CGColor {
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
