//
//  TextViewWithPlaceholder.swift
//  Anapa
//
//  Created by Олег Ковалев on 03.07.2024.
//

import UIKit

class TextViewWithPlaceholder: UITextView {
    
    let placeholderLabel: UILabel = UILabel()
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupPlaceholder()
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    func setupPlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.font = .systemFont(ofSize: 14, weight: .regular)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 20)
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
        
    }
    
    @objc func textChanged() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
