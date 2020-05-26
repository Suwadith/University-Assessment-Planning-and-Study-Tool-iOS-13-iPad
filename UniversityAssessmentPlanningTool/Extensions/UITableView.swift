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
    
    /// Sets an empty message inside the DetailView's TableView
    func setEmptyMessage(_ message: String,_ messageColour: UIColor) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = messageColour
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
}
