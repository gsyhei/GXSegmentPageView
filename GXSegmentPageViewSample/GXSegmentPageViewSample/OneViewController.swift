//
//  OneViewController.swift
//  GXSegmentPageViewSample
//
//  Created by Gin on 2020/8/18.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class OneViewController: UIViewController {
    @IBOutlet weak var numberLabel: UILabel!

    init(title: String) {
        super.init(nibName: String(describing: OneViewController.self), bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let r: CGFloat = CGFloat(50+arc4random_uniform(206))/255.0
        let g: CGFloat = CGFloat(50+arc4random_uniform(206))/255.0
        let b: CGFloat = CGFloat(50+arc4random_uniform(206))/255.0
        self.view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        self.numberLabel.text = self.title
    }
}
