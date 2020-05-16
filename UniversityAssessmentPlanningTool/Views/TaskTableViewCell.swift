//
//  TaskTableViewCell.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/15/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskDaysLeftLabel: UILabel!
    @IBOutlet weak var taskDaysLeftBar: LinearProgressBar!
    @IBOutlet weak var taskCompletionBar: CircularProgressBar!
    
    let calculations: Calculations = Calculations()
    let colours: Colours = Colours()
    let now: Date = Date()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setBars(startDate: Date, dueDate: Date, completion: Int) {
        
        let remainingDaysPercentage = calculations.getRemainingTimePercentage(startDate, end: dueDate)
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(completion)
            self.taskCompletionBar.startGradientColor = colours[0]
            self.taskCompletionBar.endGradientColor = colours[1]
            self.taskCompletionBar.progress = CGFloat(completion) / 100
        }
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(remainingDaysPercentage, negative: true)
            self.taskDaysLeftBar.startGradientColor = colours[0]
            self.taskDaysLeftBar.endGradientColor = colours[1]
            self.taskDaysLeftBar.progress = CGFloat(remainingDaysPercentage) / 100
        }
    }
    

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
