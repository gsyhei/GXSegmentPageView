//
//  GXSegmentPageView.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/18.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

@objc protocol GXSegmentPageViewDelegate: NSObjectProtocol {
    @objc optional func segmentPageView(_ page: GXSegmentPageView, progress: CGFloat)
    @objc optional func segmentPageView(_ page: GXSegmentPageView, at index: Int)
}

class GXSegmentPageView: UIView {
    public weak var delegate: GXSegmentPageViewDelegate?
    public var children: [UIViewController] = []
    private let GXCellID: String = "GXCellID"
    private(set) weak var parentViewController: UIViewController?
    private(set) var currentIndex: Int = 0
    private(set) var willIndex: Int = 0
    private var isScrollToBegin: Bool = false

    private lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = self.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: GXCellID)
        
        return collectionView
    }()

    convenience init(frame: CGRect = .zero, parent: UIViewController, children: [UIViewController]) {
        self.init(frame: frame)
        self.setupSegmentPageView(parent: parent, children: children)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layout.itemSize = self.bounds.size
        self.collectionView.frame = self.bounds
    }
}

extension GXSegmentPageView: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.children.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GXCellID, for: indexPath)
        return cell
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.willIndex = indexPath.item
        let child = children[indexPath.item]
        self.parentViewController?.addChild(child)
        child.view.frame = cell.contentView.frame
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.addSubview(child.view)
        child.didMove(toParent: self.parentViewController)
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
    }
}

extension GXSegmentPageView: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !self.isScrollToBegin && self.currentIndex != self.willIndex else { return }
        var progress: CGFloat = 1.0
        let offsetX = scrollView.contentOffset.x, width = scrollView.frame.width
        let difference = (offsetX - CGFloat(self.willIndex) * width) / width
        // Scroll to the right
        if self.currentIndex < self.willIndex {
            self.currentIndex = self.willIndex - 1
            progress = 1 + difference
        }
        // Scroll to the left
        else if self.currentIndex > self.willIndex {
            self.currentIndex = self.willIndex + 1
            progress = 1 - difference
        }
        if delegate?.responds(to: #selector(delegate?.segmentPageView(_:progress:))) ?? false {
            self.delegate?.segmentPageView?(self, progress: progress)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        guard self.currentIndex != index else { return }
        self.currentIndex = index
        if delegate?.responds(to: #selector(delegate?.segmentPageView(_:at:))) ?? false {
            self.delegate?.segmentPageView?(self, at: self.currentIndex)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isScrollToBegin = false
        if delegate?.responds(to: #selector(delegate?.segmentPageView(_:at:))) ?? false {
            self.delegate?.segmentPageView?(self, at: self.currentIndex)
        }
    }
}

extension GXSegmentPageView {
    /// Xib initializes by calling a function
    func setupSegmentPageView(parent: UIViewController, children: [UIViewController]) {
        self.parentViewController = parent
        self.children = children
        self.addSubview(self.collectionView)
    }
    func scrollToItem(to index: Int, animated: Bool) {
        guard self.currentIndex != index else { return }
        self.isScrollToBegin = true
        self.willIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        self.currentIndex = index
        if !animated {
            self.isScrollToBegin = false
            if delegate?.responds(to: #selector(delegate?.segmentPageView(_:at:))) ?? false {
                self.delegate?.segmentPageView?(self, at: index)
            }
        }
    }
    func child<T: UIViewController>(at index: Int, type: T.Type = T.self) -> T? {
        let child = self.children[index] as? T
        return child
    }
    func reloadData() {
        self.collectionView.reloadData()
    }
}
