//
//  AboutAppController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 03.02.2023.
//

import UIKit

class AboutAppController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func close(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}
