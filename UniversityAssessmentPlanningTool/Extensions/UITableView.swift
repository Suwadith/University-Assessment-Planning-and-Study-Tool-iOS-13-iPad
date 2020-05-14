//
//  UITableView.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/14/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func hasRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
}
