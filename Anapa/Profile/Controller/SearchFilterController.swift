//
//  SearchFilterController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 21.06.2023.
//

import UIKit
import PromiseKit
import Toast_Swift
import PanModal

class SearchFilterController: UIViewController {

    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var serviceCategoryView: UIView!
    @IBOutlet weak var serviceCategoryTF: UITextField!
    @IBOutlet weak var serviceSubcategoryView: UIView!
    @IBOutlet weak var serviceSubcategoryTF: UITextField!
    @IBOutlet weak var raitingView: UIView!
    @IBOutlet weak var raitingTF: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var categoryId = 0
    var categories: [Category?] = []
    var subcategoryId = 0
    var subcategories: [Category?] = []
    var raiting: Int?
    var raitingType: [String] = ["Любой", "Выше 2-х", "Выше 3-х", "Выше 4-х", "Только 5 звёзд"]

    
    var categoryPicker = UIPickerView()
    var subcategoryPicker = UIPickerView()
    var raitingPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if (UserDefaults.standard.value(forKey: "searchFilterLocation") as? String) != nil && (UserDefaults.standard.value(forKey: "searchFilterLocation") as? String) != "" {
            locationTF.text = UserDefaults.standard.string(forKey: "searchFilterLocation")
        }
        
        if (UserDefaults.standard.value(forKey: "searchFilterSubcategoryId") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterSubcategoryId") as? Int) != 0 {
            subcategoryId = UserDefaults.standard.integer(forKey: "searchFilterSubcategoryId")
        }
        
        if (UserDefaults.standard.value(forKey: "searchFilterCategoryId") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterCategoryId") as? Int) != 0 {
            categoryId = UserDefaults.standard.integer(forKey: "searchFilterCategoryId")
        }
        
        if (UserDefaults.standard.value(forKey: "searchFilterRaiting") as? Int) != nil && (UserDefaults.standard.value(forKey: "searchFilterRaiting") as? Int) != 0 {
            raiting = UserDefaults.standard.integer(forKey: "searchFilterRaiting")
            raitingTF.text = raitingType[raiting!]
        }
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        serviceCategoryTF.inputView = categoryPicker
        subcategoryPicker.delegate = self
        subcategoryPicker.dataSource = self
        serviceSubcategoryTF.inputView = subcategoryPicker
        raitingPicker.delegate = self
        raitingPicker.dataSource = self
        raitingTF.inputView = raitingPicker
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        locationView.addSmallRadius()
        serviceCategoryView.addSmallRadius()
        serviceSubcategoryView.addSmallRadius()
        raitingView.addSmallRadius()

        
        filterButton.addRadius()
        clearButton.addRadius()
        
        getCategories()
        getSubcategories(categoryId: categoryId)
    }
    

    
    // MARK: GET CATEGORIES
    func getCategories(){
        spinner.startAnimating()
        makeRequest(with: RSignUpModel.fetchCategories()) { [weak self] data in
            if let categories = data?.data {
                self?.categories = categories
                for category in self?.categories ?? [] {
                    if category?.id == self?.categoryId {
                        self?.serviceCategoryTF.text = category?.name
                    }
                }
            }
            self?.spinner.stopAnimating()
        }
    }
    
    // MARK: GET CATEGORIES
    func getSubcategories(categoryId: Int){
        spinner.startAnimating()
        makeRequest(with: RSignUpModel.fetchSubcategories(categoryId: categoryId)) { [weak self] data in
            if let subcategories = data?.data {
                self?.subcategories = subcategories
                for category in self?.subcategories ?? [] {
                    if category?.id == self?.subcategoryId {
                        self?.serviceSubcategoryTF.text = category?.name
                    }
                }
            }
            self?.spinner.stopAnimating()
        }
    }
    
    @IBAction func close(_ sender: UIButton){
        if sender == filterButton {
            if locationTF.text != "" {
                UserDefaults.standard.set(locationTF.text!, forKey: "searchFilterLocation")
            } else {
                UserDefaults.standard.set(nil, forKey: "searchFilterLocation")
            }
            
            if categoryId != 0 {
                UserDefaults.standard.set(categoryId, forKey: "searchFilterCategoryId")
            } else {
                UserDefaults.standard.set(nil, forKey: "searchFilterCategoryId")
            }
            
            if subcategoryId != 0 {
                UserDefaults.standard.set(subcategoryId, forKey: "searchFilterSubcategoryId")
            } else {
                UserDefaults.standard.set(nil, forKey: "searchFilterSubcategoryId")
            }
            
            if raiting != nil {
                UserDefaults.standard.set(raiting, forKey: "searchFilterRaiting")
            } else {
                UserDefaults.standard.set(nil, forKey: "searchFilterRaiting")
            }
            
        } else {
            UserDefaults.standard.set(nil, forKey: "searchFilterLocation")
            UserDefaults.standard.set(nil, forKey: "searchFilterCategoryId")
            UserDefaults.standard.set(nil, forKey: "searchFilterSubcategoryId")
            UserDefaults.standard.set(nil, forKey: "searchFilterRaiting")
        }
        dismiss(animated: true)
    }
}

//MARK: PICKERS
extension SearchFilterController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else if pickerView == subcategoryPicker {
            return subcategories.count
        } else {
            return raitingType.count
        }
        
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return "\(categories[row]?.name ?? "")"
        } else if pickerView == subcategoryPicker {
            return "\(subcategories[row]?.name ?? "")"
        } else {
            return raitingType[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            serviceCategoryTF.text = "\(categories[row]?.name ?? "")"
            categoryId = categories[row]?.id ?? 0
            getSubcategories(categoryId: categoryId)
        } else if pickerView == subcategoryPicker {
            serviceSubcategoryTF.text = "\(subcategories[row]?.name ?? "")"
            subcategoryId = subcategories[row]?.id ?? 0
        } else {
            raitingTF.text = raitingType[row]
            raiting = row
        }
    }
}

//MARK: - PanModalPresentable
extension SearchFilterController: PanModalPresentable {
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(340)
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        true
    }
}

