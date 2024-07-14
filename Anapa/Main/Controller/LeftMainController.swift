//
//  LeftMainController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.06.2023.
//

import UIKit

class LeftMainController: UIViewController {

    @IBOutlet weak var blur: UIVisualEffectView!
    
    var selectCategory: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    

    @objc func close(_ sender: Any){
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindMain" {
            let destinationVC = segue.destination as! MainController
            destinationVC.selectCategory = selectCategory
        }
    }
}


extension LeftMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.infoCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let leftMainCell = tableView.dequeueReusableCell(withIdentifier: "leftMainCell", for: indexPath) as! LeftMainTableViewCell
        
        leftMainCell.name.text = Constants.infoCategory[indexPath.row].name
        return leftMainCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory = indexPath.row
        performSegue(withIdentifier: "unwindMain", sender: nil)
    }
    
}
