//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import Foundation
import UIKit


//MARK: TEXT FIELD
extension UITextField {
    func addLeftPadding() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: frame.height))
        leftViewMode = .always
    }
    
    func addRightPadding() {
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: frame.height))
        rightViewMode = .always
    }
    
    func addBigLeftPadding() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: frame.height))
        leftViewMode = .always
    }
}



//MARK: VIEW CONTROLLER
extension UIViewController {
    //    hide keybboard for tap on view
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    //MARK: EXIT APP
    func exitAppClearKeychain() {
        let exitAlert = UIAlertController(title: "Внимание", message: "Вы уверены что хотите выйти из из профиля?", preferredStyle: .alert)
        let okAciton = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            
            UserDefaults.standard.set(0, forKey: "id")
            UserDefaults.standard.set(false, forKey: "isRegistered")
            UserDefaults.standard.set("", forKey: "email")
            UserDefaults.standard.set("", forKey: "tel")
            UserDefaults.standard.set("", forKey: "firstName")
            UserDefaults.standard.set("", forKey: "lastName")
            UserDefaults.standard.set("", forKey: "patronymic")
            UserDefaults.standard.set(0, forKey: "birthtime")
            UserDefaults.standard.set(nil, forKey: "gender")
            UserDefaults.standard.set("", forKey: "avatar")
            UserDefaults.standard.set(nil, forKey: "location")
            UserDefaults.standard.set(0.0, forKey: "rating")
            UserDefaults.standard.set(nil, forKey: "categoryId")
            UserDefaults.standard.set(Data(), forKey: "category")
            UserDefaults.standard.set(nil, forKey: "lastVisited")
            UserDefaults.standard.set("", forKey: "lastVisitedHuman")
            UserDefaults.standard.set(true, forKey: "isActive")
            UserDefaults.standard.set(false, forKey: "isSuperuser")

            UserDefaults.standard.set(0, forKey: "storiesCount")
            UserDefaults.standard.set(0, forKey: "hugsCount")
            UserDefaults.standard.set(true, forKey: "isOnline")
            UserDefaults.standard.set(false, forKey: "iBlock")
            UserDefaults.standard.set(false, forKey: "blockMe")
            
            UserDefaults.standard.set(0, forKey: "createdOrdersCount")
            UserDefaults.standard.set(0, forKey: "completedOrdersCount")
            UserDefaults.standard.set(0, forKey: "myOffersCount")
            
            UserDefaults.standard.set(0, forKey: "tg")
            
            UserDefaults.standard.set(false, forKey: "isServicer")
            UserDefaults.standard.set(false, forKey: "showTel")
            
            UserDefaults.standard.set("", forKey: "firebaseToken")
            
            self?.clearKeychain()
            
            let sBoard = UIStoryboard(name: "Initial", bundle: .main)
            let vc = sBoard.instantiateInitialViewController()
            
            vc?.modalPresentationStyle = .fullScreen
            self?.present(vc!, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        exitAlert.addAction(okAciton)
        exitAlert.addAction(cancelAction)
        present(exitAlert, animated: true)
    }
    
    func clearKeychain(){
        do {
            try Constants.keychain.removeAll()
        } catch {
            
        }
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        
        let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) ?? ""
        
        return "\(formattedAmount) ₽"
    }
    
    func removeSpaces(from inputString: String) -> String {
        let stringWithoutSpaces = inputString.replacingOccurrences(of: " ", with: "")
        return stringWithoutSpaces
    }
    
    func addIndentInText(text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10
        let attributedString = NSAttributedString(string: text + "  ", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return attributedString
    }
    
    func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, env in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(30),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(32)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            
            return section
        }
    }
    
    func returnStringYear(seconds: Int) -> String {
        var years = ""
        let birthdate = Date(timeIntervalSince1970: TimeInterval(seconds))
        let now = Date()

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
        if let age = ageComponents.year {
            years = "\(age)"
        }
        return years
    }
}

// MARK: SET GRADIENT TO VIEW
@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}

//MARK: ADD SHADOW FOR VIEW
extension UIView {
    
    func setOval(){
        layer.cornerRadius = self.frame.size.height / 2
    }
    
    func addSmallRadius() {
        layer.cornerRadius = 8
    }
    
    func addRadius() {
        layer.cornerRadius = 10
    }
    
    func smallWhiteBorder(){
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    func smallBlackBorder(){
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func smallBlackBorder2(){
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "AppBlack")?.cgColor
    }
    
    func blackBorder(){
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func greenBorder(){
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
    }
    
    func greyBorder(){
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }
    
    func bigRadius(){
        clipsToBounds = true
        layer.cornerRadius = 16
    }
    
    func smallTopRadius(){
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func topRadius(){
        clipsToBounds = true
        layer.cornerRadius = 25
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func smallBottomRadius(){
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func bottomRadius(){
        clipsToBounds = true
        layer.cornerRadius = 25
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func bottomPageRadius(){
        clipsToBounds = true
        layer.cornerRadius = 17
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func addGreyShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.21).cgColor
        layer.shadowOpacity = 2
        layer.shadowOffset = CGSize(width: 2, height: 6)
        layer.shadowRadius = 12
    }
    
    func addHardGreyShadow() {
        layer.masksToBounds = false
        if UserDefaults.standard.string(forKey: "colorTheme") == "Light"{
            layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        } else {
            layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        }
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 7, height: 10)
        layer.shadowRadius = 17
    }
    
    func applyGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, width: Int, height: Int) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.opacity = 1.0
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}



// MARK: CAPITALIZATION FIRST CHAR
extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased()  + dropFirst()
    }
}

//MARK: UNIX TIME
typealias UnixTime = Int

extension UnixTime {
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: Date {
        return Date(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType(form: "HH").string(from: dateFull)
    }
    var toHourAndMinute: String {
        return formatType(form: "HH:mm").string(from: dateFull)
    }
    var toDay: String {
        return formatType(form: "dd.MM.yyyy").string(from: dateFull)
    }
    var toDayAndHour: String {
        return formatType(form: "dd.MM.yyyy HH:mm").string(from: dateFull)
    }
    var withdrawRent: String {
        return formatType(form: "До вывода dd дней HH часов mm минут").string(from: dateFull)
    }
    
    var toMonth: String {
        return formatType(form: "LLLL yyyy").string(from: dateFull).firstUppercased
    }
}

// MARK: HASHABLE ARRAY
extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}


//MARK: UNIQUE
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

//MARK: FIXED IMAGE ORIENTATION
extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

//MARK: EMAIL VALIDATION
extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}


//MARK: SECURE TEXT FIELD

extension UITextField {
    enum EyeColor {
        case white
        case violet
    }
    
    func enablePasswordToggle(color: EyeColor){
        let secureButton = UIButton(type: .custom)
        if color == .white {
            secureButton.setImage(UIImage(named: "CloseEye"), for: .normal)
            secureButton.setImage(UIImage(named: "OpenEye"), for: .selected)
        } else if color == .violet {
            secureButton.setImage(UIImage(named: "VioletCloseEye"), for: .normal)
            secureButton.setImage(UIImage(named: "VioletOpenEye"), for: .selected)
        }
        
        secureButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        secureButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        rightView = secureButton
        rightViewMode = .always
        secureButton.alpha = 0.8
    }
    
    @objc func togglePasswordView(_ sender: UIButton) {
        isSecureTextEntry.toggle()
        sender.isSelected.toggle()
    }

}



//MARK: HEX COLOR
extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
            
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

    
}


// MARK: - UIButton
extension UIButton {
    func changeTextAndFont(text: String, font: UIFont, fontColor: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor
        ]
        
        let attributedTitle = NSAttributedString(string: text, attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func addSmallGreyShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2) // Размер смещения тени
        self.layer.shadowOpacity = 0.3 // Прозрачность тени
        self.layer.shadowRadius = 2 // Радиус размытия тени
    }

}

// MARK: - UILabel
extension UITextView {
    func addContainerInset() {
        self.textContainerInset = UIEdgeInsets(top: 19, left: 0, bottom: 0, right: 0)
    }
}
