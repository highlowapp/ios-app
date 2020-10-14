//
//  TextFieldTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 8/21/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextViewDelegate {
    
    let textField: UITextView = UITextView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addSubview(textField)
        
        textField.eqTop(self.contentView).eqLeading(self.contentView, 10).eqTrailing(self.contentView, -10).height(200)
        
        self.contentView.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        
        textField.isScrollEnabled = true
        textField.font = .preferredFont(forTextStyle: .body)
        
        textField.textColor = .lightGray
        textField.text = "Enter your own focus"
        
        textField.delegate = self
        textField.keyboardDismissMode = .onDrag
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter custom focus"
            textView.textColor = UIColor.lightGray
        }
    }

}
