//
//  ViewController.swift
//  DePangrammer
//
//  Created by Aaron Nance on 1/8/22.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    var dictionary = [String]()
    var pangram = ""
    
    
    // MARK: - Outlets
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var output: UILabel!
    
    
    // MARK: - Actions
    // MARK: - Overrides
    
    
    // MARK: - Custom Methods
    override func viewDidLoad() {
        
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        
        view.addGestureRecognizer(hideKeyboard)
        
        input.delegate = self
        
        super.viewDidLoad()
        
    }
    
    @objc func hideKeyboard(_ sender: Any) {
        
        if input.isFirstResponder {
            
            print(type(of: sender))
            
            input.resignFirstResponder()
            
        }
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if input.text!.count == 7 {
            
            input.resignFirstResponder()
            
            let word = input.text!
                    
            let solution = Solver.shared.analyze(word)
            
            var text = ""
            for word in solution {
                text += "\(word)[\(word.count)] "
            }
            
            output.text = text
            
            return true
            
        } else {
            
            output.text = "Invalid Input\nRequired 7 Letter Pangram"
            return false
            
        }
        
    }
    
}
