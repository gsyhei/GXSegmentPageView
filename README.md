# GXSegmentPageView
Swift版分段分页组件，（网易新闻、腾讯新闻、新浪微博、今日头条等Tab效果）。
有建议可以联系QQ交流群:1101980843，喜欢就给个star哦，谢谢关注！
<p align="center">
<img src="https://github.com/gsyhei/GXCardView-Swift/blob/master/QQ.jpeg">
</p>

先上Demo效果图
--
<p align="center">
<img src="https://github.com/gsyhei/GXSegmentPageView/blob/master/GXSegmentPageView.gif">
</p>

Requirements
--
<p align="left">
<a href="https://github.com/gsyhei/GXSegmentPageView"><img src="https://img.shields.io/badge/platform-ios%209.0-yellow.svg"></a>
<a href="https://github.com/gsyhei/GXSegmentPageView"><img src="https://img.shields.io/github/license/johnlui/Pitaya.svg?style=flat"></a>
<a href="https://github.com/gsyhei/GXSegmentPageView"><img src="https://img.shields.io/badge/language-Swift%204.2-orange.svg"></a>
</p>

Usage in you Podfile:
--

```
pod 'GXSegmentPageView'
```

GXSegmentTitleView
--

```swift
// 代码创建
let config = GXSegmentTitleView.Configuration()
config.positionStyle = .none
config.indicatorStyle = .dynamic
config.indicatorFixedWidth = 30.0
config.indicatorFixedHeight = 2.0
config.indicatorAdditionWidthMargin = 5.0
config.indicatorAdditionHeightMargin = 2.0
config.isShowSeparator = true
config.separatorInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
let titleView = GXSegmentTitleView(frame: self.bounds, config: config, titles: titles)

// XIB创建需要调用此方法配置数据
@IBOutlet weak var titleView: GXSegmentTitleView!
self.titleView.setupSegmentTitleView(config: config, titles: self.items)

// 回调代理方法
@objc protocol GXSegmentTitleViewDelegate: NSObjectProtocol {
    @objc optional func segmentTitleView(_ page: GXSegmentTitleView, at index: Int)
}
```

GXSegmentPageView
--

```swift
// 代码创建
let pageView: GXSegmentPageView = GXSegmentPageView(parent: self, children: childVCs)

// XIB创建需要调用此方法配置数据
@IBOutlet weak var pageView: GXSegmentPageView!
self.pageView.setupSegmentPageView(parent: self, children: childVCs)

```

GXSegmentTitleView &  GXSegmentPageView
--

```swift

// 两个控件联动使用只需实现两者的代理

extension ViewController: GXSegmentPageViewDelegate {
    func segmentPageView(_ segmentPageView: GXSegmentPageView, at index: Int) {
        NSLog("index = %d", index)
    }
    func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat) {
        self.titleView.setSegmentTitleView(currentIndex: page.selectIndex, willIndex: page.willSelectIndex, progress: progress)
    }
}

extension ViewController: GXSegmentTitleViewDelegate {
    func segmentTitleView(_ page: GXSegmentTitleView, at index: Int) {
        self.pageView.scrollToItem(to: index, animated: true)
    }
}

```

License
--
MIT


