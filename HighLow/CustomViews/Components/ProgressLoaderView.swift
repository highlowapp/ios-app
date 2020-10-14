//
//  ProgressLoaderView.swift
//  HighLow
//
//  Created by Caleb Hester on 8/4/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ProgressLoaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    let progress: UIProgressView = UIProgressView()
    let title: UILabel = UILabel()
    let skip: UIButton = UIButton()
    
    var allowsSkip: Bool = false {
        didSet {
            skip.isHidden = !allowsSkip
        }
    }
    
    weak var delegate: ProgressLoaderViewDelegate?
    
    private func setup() {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        let container = UIView()
        self.addSubview(blurView)
        blurView.eqLeading(self).eqTrailing(self).eqTop(self).eqBottom(self)
        
        blurView.contentView.addSubview(container)
        container.addSubviews([progress, title, skip])
        
        title.text = "Loading..."
        title.textColor = .lightGray
        title.textAlignment = .center
        
        title.eqLeading(container).eqTrailing(container).eqTop(container)
        
        progress.eqWidth(container, 0, 0.8).topToBottom(title, 10).centerX(container)
        
        skip.setTitle("Skip", for: .normal)
        skip.setTitleColor(AppColors.primary, for: .normal)
        skip.eqLeading(container).eqTrailing(container).topToBottom(progress, 10).height(50)
        skip.addTarget(self, action: #selector(skipProcess), for: .touchUpInside)
        skip.isHidden = !allowsSkip
        skip.isUserInteractionEnabled = true
        
        container.eqBottom(skip).eqLeading(blurView).eqTrailing(blurView).centerY(blurView)
        
        progress.progressTintColor = AppColors.primary
    }
    
    func setProgress(_ x: Float) {
        progress.setProgress(x, animated: true)
    }
    
    func setTitle(_ title: String) {
        self.title.text = title
    }
    
    @objc func skipProcess() {
        delegate?.didSkip()
    }

}
protocol ProgressLoaderViewDelegate: AnyObject {
    func didSkip()
}
