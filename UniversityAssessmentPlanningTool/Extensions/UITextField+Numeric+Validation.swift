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
    
}
