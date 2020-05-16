//
//  EditTaskViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/15/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class EditTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskNotesField: UITextField!
    @IBOutlet weak var taskReminderSwitch: UISwitch!
    @IBOutlet weak var taskCompletionSlider: UISlider!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var taskStartDateLabel: UILabel!
    @IBOutlet weak var taskStartDatePicker: UIDatePicker!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskDueDatePicker: UIDatePicker!
    @IBOutlet weak var taskUpdateButton: UIButton!
    
    
    var tasks: [NSManagedObject] = []
    
    var selectedAssessment: Assessment?
    
    let dateFormatter = DateFormatter()
    
    let eventStore = EKEventStore()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dateFormatter.styleDate()
        
        eventStore.requestAccess(to: .event, completion: {_,_ in })
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = task {
            if let taskName = taskNameField {
                taskName.text = detail.taskName
            }
            if let taskNotes = taskNotesField {
                taskNotes.text = detail.taskNotes
            }
            if let taskDueReminder = taskReminderSwitch {
                taskDueReminder.isOn = detail.taskDueReminder
            }
            if let taskCompletion = taskCompletionSlider {
                taskCompletion.value = Float(detail.taskCompletion)
            }
            if let taskCompletionStr = taskCompletionLabel {
                taskCompletionStr.text = String(detail.taskCompletion) + "% Completed"
            }
            if let taskStartStr = taskStartDateLabel {
                taskStartStr.text = dateFormatter.string(from: detail.taskStartDate!)
            }
            if let taskStartPicker = taskStartDatePicker {
                taskStartPicker.date = detail.taskStartDate!
            }
            if let taskDueStr = taskDueDateLabel {
                taskDueStr.text = dateFormatter.string(from: detail.taskDueDate!)
            }
            if let taskDuePicker = taskDueDatePicker {
                taskDuePicker.date = detail.taskDueDate!
            }
        }
    }
    
    var task: Task? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
