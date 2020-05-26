//
//  UITextField+Numeric+Validation.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/26/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    /// Makes sure the Marks and Value input fields are using numeric inputs
    func checkIfNumeric() -> Bool {
        
        let numbersSet = CharacterSet(charactersIn: "0123456789")
        
        var isNumeric = true
    
        let textCharacterSet = CharacterSet(charactersIn: self.text!)
        
        if textCharacterSet.isSubset(of: numbersSet) {
            print("text only contains numbers 0-9")
        } else {
            print("text contains invalid characters")
            isNumeric = false
        }
        
        return isNumeric
    }
    
    
    /// Makes sure that the Marks and Value input fields have valid range of numbers
    func checkIfMakrsWithinRange() -> Bool {
        
        var isWithinRange = true
        
        let input = Int(self.text!)
        
        if input! < 0 || input! > 100 {
            isWithinRange = false
        }
        return isWithinRange
    }
    
}
