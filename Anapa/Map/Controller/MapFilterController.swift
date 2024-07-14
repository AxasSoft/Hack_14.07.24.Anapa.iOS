//
//  MapFilterController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 16.09.2023.
//

import UIKit
import PromiseKit

class MapFilterController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var categories: [Category?] = []
    var selectedСategories: [Category?] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        filterTable.delegate = self
        filterTable.dataSource = self

    }

    override func viewWillAppear(_ animated: Bool) {
        confirmButton.addRadius()
        cancelButton.addRadius()
        getCategories()

        filterTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(selectedСategories), forKey: "mapFilterCategory")
    }
    
    
    // MARK: GET CATEGORIES
    func getCategories(){
        spinner.startAnimating()
        makeRequest(with: RSignUpModel.fetchCategories()) { [weak self] data in
            if let categories = data?.data {
                self?.categories = categories
                if let data = UserDefaults.standard.value(forKey:"mapFilterCategory") as? Data {
                    if data.count > 0 {
                        
                        self?.selectedСategories = try! PropertyListDecoder().decode(Array<Category>.self, 
                                                                                    from: data)
                    }
                }
                self?.spinner.stopAnimating()
                self?.filterTable.reloadData()
            }
        }
    }
    
    @IBAction func confirmCategory(_ sender: UIButton){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(selectedСategories), forKey: "mapFilterCategory")
        self.performSegue(withIdentifier: "unwindMap", sender: nil)
    }
    
    @IBAction func cancelCategory(_ sender: UIButton){
        selectedСategories = []
        UserDefaults.standard.set(try? PropertyListEncoder().encode(selectedСategories), forKey: "mapFilterCategory")
        self.performSegue(withIdentifier: "unwindMap", sender: nil)
    }
}



//MARK: TABLE
extension MapFilterController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterCell = tableView.dequeueReusableCell(withIdentifier: "mapFilterCell", for: indexPath) as! MapFilterTableViewCell
        
        filterCell.name.text = categories[indexPath.row]?.name ?? ""
        
        if selectedСategories.contains(where: {$0 == categories[indexPath.row]}) {
            filterCell.activeImage.image = UIImage(named: "CheckBoxCircleActive")
        } else {
            filterCell.activeImage.image = UIImage(named: "CheckBoxCircleInactive")
        }
        
        return filterCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedСategories.contains(where: {$0 == categories[indexPath.row]}) {
            for i in 0..<selectedСategories.count {
                if selectedСategories[i]?.id == categories[indexPath.row]?.id {
                    selectedСategories.remove(at: i)
                    filterTable.reloadData()
                    return
                }
            }
        } else {
            selectedСategories.append(categories[indexPath.row])
            filterTable.reloadData()
            return
        }
    }
    
}
