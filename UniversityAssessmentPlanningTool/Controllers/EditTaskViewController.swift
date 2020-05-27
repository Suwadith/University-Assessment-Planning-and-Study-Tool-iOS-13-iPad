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
    
    let currentDate = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.styleDate()
        let currentDate = Date()
        
        /// Makes sure the task start date is atleast 1 miniute from now
        /// Makes sure the task start date onlly goes upto the assessment due date
        var startDateComponent = DateComponents()
        startDateComponent.minute = 1
        taskStartDatePicker.minimumDate = task?.taskStartDate
        taskStartDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        /// Makes sure the task due date is atleast 31 miniute from now
        /// Makes sure the task due date onlly goes upto the assessment due date
        var dueDateComponent = DateComponents()
        dueDateComponent.minute = 31
        let dueDate = Calendar.current.date(byAdding: dueDateComponent, to: currentDate)!
        taskDueDatePicker.minimumDate = dueDate
        taskDueDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        /// Onload requests for calendar access for reminder functionality
        eventStore.requestAccess(to: .event, completion: {_,_ in })
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Populates the edit Task form fields according to their relevant attributes
    func configureView() {
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
    
    /// Populates the edit Task form fields if Task data is clicked and available within the core data DB
    var task: Task? {
        didSet {
            configureView()
        }
    }
    
    /// Editing Task data
    @IBAction func onUpdate(_ sender: Any) {
        
        /// Makes sure the needed input fields are not empty while editing an Task entry
        if taskNameField.text?.isEmpty == false && taskNotesField.text?.isEmpty == false {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            /// Copies the selected Task Object
            let object = task!
            
            /// Updates the copied object with the new edited Task field values
            object.setValue(taskNameField.text!, forKeyPath: "taskName")
            object.setValue(taskNotesField.text!, forKeyPath: "taskNotes")
            object.setValue(taskReminderSwitch.isOn, forKeyPath: "taskDueReminder")
            object.setValue(taskCompletionSlider.value, forKeyPath: "taskCompletion")
            object.setValue(taskStartDatePicker.date, forKeyPath: "taskStartDate")
            object.setValue(taskDueDatePicker.date, forKeyPath: "taskDueDate")
            
            do {
                /// Checks if the Task has already been added to the calender and deletes if it already does
                if object.taskReminderIdentifier != "" {
                    let reminder = Reminder()
                    reminder.deleteEvent(eventIdentifier: object.taskReminderIdentifier!)
                    object.setValue("", forKey: "taskReminderIdentifier")
                }
                
                /// If reminder option is choosen then the new reminder date is added to the calendar
                if taskReminderSwitch.isOn {
                    let reminderIdentifier = addToCalendar(calendarSwitch: taskReminderSwitch.isOn, taskName: taskNameField.text!, startDate: taskStartDatePicker.date, dueDate: taskDueDatePicker.date)
                    object.setValue(reminderIdentifier, forKey: "taskReminderIdentifier")
                }
                
                /// Saves the modified Task Object
                try managedContext.save()
                dismissPopOver()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            showAlert(title: "Error", msg: "Only the notes field can be left empty")
        }
        
        
    }
    
    /// Saves a reminder if the user chooses the option
    func addToCalendar(calendarSwitch: Bool, taskName: String, startDate: Date, dueDate: Date) -> String {
        var reminderIdentifier = ""
        if calendarSwitch {
            let reminder = Reminder()
            reminderIdentifier = reminder.createTaskEvent(title: taskName, startDate: startDate, dueDate: dueDate)
        }
        return reminderIdentifier
    }
    
    /// While sliding the completion slider updates the completion label
    @IBAction func onSliderChange(_ sender: UISlider) {
        taskCompletionLabel.text = String(Int(sender.value)) + "% Completed"
    }
    
    /// While scrolling start DatePicker updates the text start date value appropriately
    @IBAction func onStartDateChange(_ sender: Any) {
        let strDate = dateFormatter.string(from: taskStartDatePicker.date)
        taskStartDateLabel.text = strDate
    }
    
    /// While scrolling due DatePicker updates the text due date value appropriately
    @IBAction func onDueDateChange(_ sender: Any) {
        let strDate = dateFormatter.string(from: taskDueDatePicker.date)
        taskDueDateLabel.text = strDate
    }
    
}
