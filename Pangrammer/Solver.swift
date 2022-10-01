
//  Words.swift
//  Pangrammer
//
//  Created by Aaron Nance on 1/8/22.
//

import UIKit
import APNUtil

class Solver
{
    static var shared = Solver()
    
    // MARK: - Properties
    private var getCounter = 0 { didSet { checkGetCount() } }

    private var allWords: [String] { getWords() }
    private var _allWords = [String]()
    
    /// Is a dictionary keyed on the sets of unique letters contained in each possible pangram solution.
    /// - note: This key can then be compared against the set of characters in the pangram word to see
    /// if it is a strict subset containing the middle character.
    ///
    /// e.g. the key for word "collective" would be the `Set<Character>` `["c", "o", "l", "e", "t", "v"]`
    ///
    private var charsToWords: [Set<Character> : [String]] { getSolutions() }
    private var _charsToWords = [Set<Character> : [String]]()
    
    
    // MARK: - Custom Methods
    /// Helper method for checking that `getGords()` and `getSolutions()` aren't called more
    /// than once each.
    private func checkGetCount() {
        
        let expected = 2
        
        assert( getCounter <= expected,
                "Data initialized more than expected. Expected: \(expected) - Found: \(getCounter)")
        
    }
    
    private func getWords() -> [String]
    {
        if !_allWords.isEmpty {
            
            return _allWords /*EXIT*/
            
        }
        
        getCounter += 1
        
        // NOTE: this file contains only words matching 7 letter pangrams.
        let file = (name:"words.edited.possible.solutions", type: "txt")
        
        if let path = Bundle.main.path(forResource: file.name, ofType: file.type) {
            
            do {
                
                let text = try String(contentsOfFile: path)
                _allWords = text.components(separatedBy: "\n")
                
            } catch { print("Error reading file: \(path)") }
            
        }
        
        return _allWords /*EXIT*/
            
    }
  
    private func getSolutions() -> [Set<Character> : [String] ] {
                
        if !_charsToWords.isEmpty {
            
            return _charsToWords /*EXIT*/
            
        }
        
        getCounter += 1
        
        var invalids = [String]()
        
        var chars = Set<String>()
        var set = Set<Character>()
        
        for word in allWords {
            
            if word.count < 4 { invalids.append(word); continue /*CONTINUE*/ }
            
            chars.removeAll()
            set.removeAll()
            
            for char in word {
                
                chars.insert(String(char))
                if chars.count > 7 { break /*BREAK*/ }
                
                set.insert(char)
                
            }
            
            if chars.count > 7 { invalids.append(word); continue /*CONTINUE*/ }
            
            if _charsToWords[set] == nil {
                
                _charsToWords[set] = [String]()
                
            }
            
            _charsToWords[set]!.append(word)
            
        }
        
        return _charsToWords
        
    }
    
    private func generatePangramKey(_ word: String) -> Set<Character> {
        
        var set = Set<Character>()
        let word = word.lowercased()
        
        for char in word {
            
            set.insert(char)
            
        }
        
        return set
        
    }
    
    /// Checks `word` for all contained words, returns `[String]` containing matching anagram words,
    /// uppercasing pangrams.
    func analyze(_ word: String) -> (anagrams: [String], pangrams:[String]) {
        
        if word.count != 7 { return (["Invalid Input"], []) /*EXIT*/ }
        let word = word.lowercased()
        
        let pangramKey  = generatePangramKey(word)
        var anagrams    = [String]()
        var pangrams    = [String]()
        
        let centerIndex = word.index(word.startIndex, offsetBy: 3)
        let centerLetter = word[centerIndex]
        
        let cToW = charsToWords
        
        for key in cToW.keys {
            
            if key.isSubset(of: pangramKey) && key.contains(centerLetter) {
                
                let matches = cToW[key] ?? []
                
                if key.count == 7 {
                    
                    pangrams.append(contentsOf: matches)
                    
                }
                
                anagrams.append(contentsOf: matches)
                
            }
            
        }
        
        anagrams = anagrams.sorted(){ $1.count < $0.count }
        pangrams = pangrams.sorted(){ $1.count < $0.count }
        
        return (anagrams, pangrams)
        
    }
    
}
