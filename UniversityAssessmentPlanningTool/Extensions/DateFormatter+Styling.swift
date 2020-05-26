//
//  DateFormatter+Styling.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/13/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// Specifies a short style, “11/23/37” and “3:30 PM”.
    func styleDate() {
        self.dateStyle = DateFormatter.Style.short
        self.timeStyle = DateFormatter.Style.short
    }
    
}
