//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit

private extension TimeInterval {
    static let animation250ms: TimeInterval = 0.25
}

private extension UIColor {
    static let inactive: UIColor = UIColor(named: "VioletText") ?? .white
}

private enum ConstantsTF {
    static let offset: CGFloat = 8
    static let placeholderSize: CGFloat = 14
}

final class FloatingTextField: UITextField {

    // MARK: - Subviews
    private var border = UIView()
    private var label = UILabel()

    // MARK: - Private Properties
    private var scale: CGFloat {
        ConstantsTF.placeholderSize / fontSize
    }

    private var fontSize: CGFloat {
        font?.pointSize ?? 0
    }

    private var labelHeight: CGFloat {
        ceil(font?.withSize(ConstantsTF.placeholderSize).lineHeight ?? 0)
    }

    private var textHeight: CGFloat {
        ceil(font?.lineHeight ?? 0)
    }

    private var isEmpty: Bool {
        text?.isEmpty ?? true
    }

    private var textInsets: UIEdgeInsets {
        UIEdgeInsets(top: ConstantsTF.offset + labelHeight, left: 0, bottom: ConstantsTF.offset, right: 0)
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UITextField
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: textInsets.top + textHeight + textInsets.bottom)
    }

    override var placeholder: String? {
        didSet {
            label.text = placeholder
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        updateLabel(animated: false)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard !isFirstResponder else {
            return
        }

        label.transform = .identity
        label.frame = bounds.inset(by: textInsets)
    }

    // MARK: - Private Methods
    private func setupUI() {
        borderStyle = .none

        border.backgroundColor = .inactive
        border.isUserInteractionEnabled = false
        addSubview(border)

        label.textColor = .inactive
        label.font = font
        label.text = placeholder
        label.isUserInteractionEnabled = false
        addSubview(label)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: frame.height))
        leftViewMode = .always

        addTarget(self, action: #selector(handleEditing), for: .allEditingEvents)
    }
    


    @objc
    private func handleEditing() {
        updateLabel()
        updateBorder()
    }

    private func updateBorder() {
        let borderColor = isFirstResponder ? tintColor : .inactive
        UIView.animate(withDuration: .animation250ms) {
            self.border.backgroundColor = borderColor
        }
    }

    private func updateLabel(animated: Bool = true) {
        let isActive = isFirstResponder || !isEmpty

        let offsetX = -label.bounds.width * (1 - scale) / 2
        let offsetY = -label.bounds.height * (1 - scale) / 2

        let transform = CGAffineTransform(translationX: offsetX, y: offsetY - labelHeight - ConstantsTF.offset)
            .scaledBy(x: scale, y: scale)

        guard animated else {
            label.transform = isActive ? transform : .identity
            return
        }

        UIView.animate(withDuration: .animation250ms) {
            self.label.transform = isActive ? transform : .identity
        }
    }
}
