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
    @IBOutlet weak var output: UITextView!
    
    
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

    enum TextStyle { case head1, head2, pangram, anagram}
    
    func builAttributed(text: String,
                        style: TextStyle,
                        base: NSMutableAttributedString) {
        
        var atts = [NSAttributedString.Key : Any]()
        atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 11.0)!

        switch style {
            
        case .head1:
            
            atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 30.0)!
            atts[NSAttributedString.Key.foregroundColor] = UIColor.white
            
            
        case .head2:
            atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 12.0)!
            atts[NSAttributedString.Key.foregroundColor] = UIColor.white
            
        case .pangram:
            
            atts[NSAttributedString.Key.foregroundColor] = UIColor.systemYellow
            
        case .anagram:
            
            atts[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
            
        }
        
        let new = NSMutableAttributedString(string: text,
                                            attributes: atts)
        
        base.append(new)
        
    }
    
    func setTitle(text: String) {
        
        let base = NSMutableAttributedString()
        
        builAttributed(text: text.uppercased(),
                       style: .head1,
                       base: base)
        
        let range = NSRange(location: 3, length: 1)
        
        base.addAttribute(NSAttributedString.Key.foregroundColor,
                          value: UIColor.systemYellow,
                          range: range)
        
        self.input.text = ""
        self.input.attributedText = base
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if input.text!.count == 7 {

            DispatchQueue.main.async {

                let word = self.input.text!
                
                self.setTitle(text: word)
                
                self.input.resignFirstResponder()
                
                let (all, pan) = Solver.shared.analyze(word)

                let myString = NSMutableAttributedString()
                
                self.builAttributed(text: "",
                                    style: .pangram,
                                    base: myString)
                
                if pan.count > 0 {
                    self.builAttributed(text: "PANGRAMS(\(pan.count)):\n",
                                        style: .head2,
                                        base: myString)
                }
                                
                pan.forEach{
                    
                    self.builAttributed(text: "\($0) - \($0.count)\n",
                                        style: .pangram,
                                        base: myString)
                                        
                }
                
                self.builAttributed(text: "\nANAGRAMS(\(all.count)):\n",
                                    style: .head2,
                                    base: myString)
                
                all.forEach{

                    self.builAttributed(text: "\($0) - \($0.count)\n",
                                        style: .anagram,
                                        base: myString)

                }
                
                self.output.attributedText = myString
                
            }
                
            return true
            
        } else {
            
            output.text = "Invalid Input\nRequired 7 Letter Pangram"
            return false
            
        }
        
    }
    
}
