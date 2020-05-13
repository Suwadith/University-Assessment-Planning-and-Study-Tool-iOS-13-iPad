//
//  MyCustomTableViewCell.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/13/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit

class MyCustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var assessmentModuleNameLable: UILabel!
    @IBOutlet weak var assessmentNameLabel: UILabel!
    @IBOutlet weak var assessmentValueLabel: UILabel!
    @IBOutlet weak var assessmentMarkLabel: UILabel!
    @IBOutlet weak var assessmentDueDateLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        print(assessmentModuleNameLable.text!)
//        // Configure the view for the selected state
//    }
//    
    

}
