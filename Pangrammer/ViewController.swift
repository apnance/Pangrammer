//
//  ViewController.swift
//  Pangrammer
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
        output.layer.cornerRadius = 3
        
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
    
    private enum TextStyle { case head1, head2, pangram, pangramBest, anagram, errorHead, error1, error2}
    
    private func builAttributed(text: String,
                                style: TextStyle,
                                base: NSMutableAttributedString) {
        
        var atts = [NSAttributedString.Key : Any]()
        atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 11.0)!
        
        switch style {
                
            case .head1:
                
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 30.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.white
                
                
            case .head2:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Bold", size: 12.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.white
                
            case .pangram:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Bold", size: 11.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.systemYellow
                
            case .pangramBest:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Bold", size: 11.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.systemRed
                
            case .anagram:
                
                atts[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
                
            case .errorHead:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Bold", size: 12.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.systemRed
                
            case .error1:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura-Medium", size: 11.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.systemYellow
                
            case .error2:
                atts[ NSAttributedString.Key.font] =  UIFont(name: "Futura", size: 11.0)!
                atts[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
                
        }
        
        let new = NSMutableAttributedString(string: text,
                                            attributes: atts)
        
        base.append(new)
        
    }
    
    func setTitle(text: String) {
        
        let baseMAS = NSMutableAttributedString()
        
        builAttributed(text: text.uppercased(),
                       style: .head1,
                       base: baseMAS)
        
        let range = NSRange(location: 3, length: 1)
        
        baseMAS.addAttribute(NSAttributedString.Key.foregroundColor,
                             value: UIColor.systemYellow,
                             range: range)
        
        self.input.text             = ""
        self.input.attributedText   = baseMAS
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        var success = true
        let input   = String(Array(input.text!).dedupe())
        let baseMAS = NSMutableAttributedString()
        
        switch input.count {
                
            case 7:
                
                self.input.text = input
                
                self.setTitle(text: input)
                
                self.input.resignFirstResponder()
                
                let (all, pan) = Solver.shared.analyze(input)
                
                self.builAttributed(text: "",
                                    style: .pangram,
                                    base: baseMAS)
                
                if pan.count > 0 {
                    self.builAttributed(text: "PANGRAMS(\(pan.count)):\n",
                                        style: .head2,
                                        base: baseMAS)
                }
                
                var style: TextStyle = .pangramBest
                pan.forEach{
                    
                    self.builAttributed(text: "\($0) - \($0.count)\n",
                                        style: style,
                                        base: baseMAS)
                    
                    style = .pangram
                    
                }
                
                self.builAttributed(text: "\nANAGRAMS(\(all.count)):\n",
                                    style: .head2,
                                    base: baseMAS)
                
                all.forEach{
                    
                    self.builAttributed(text: "\($0) - \($0.count)\n",
                                        style: .anagram,
                                        base: baseMAS)
                    
                }
                
                success = true
                
            default:
                
                let text = input.count > 7 ? "many" : "few"
                
                self.builAttributed(text: "Invalid Input:\n",
                                    style: .errorHead,
                                    base: baseMAS)
                
                self.builAttributed(text: "Too \(text) characters(\(input.count)) - ",
                                    style: .error1,
                                    base: baseMAS)
                
                self.builAttributed(text: "Pangram input must be 7 unique characters.",
                                    style: .error2,
                                    base: baseMAS)
                
                success = false
                
        }
        
        DispatchQueue.main.async { self.output.attributedText = baseMAS }
        
        return success /*EXIT*/
        
    }
    
}
