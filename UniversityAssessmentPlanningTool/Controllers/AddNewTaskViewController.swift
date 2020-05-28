//
//  AddNewTaskViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/15/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddNewTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskNotesField: UITextField!
    @IBOutlet weak var taskReminderSwitch: UISwitch!
    @IBOutlet weak var taskCompletionSlider: UISlider!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var taskStartDateLabel: UILabel!
    @IBOutlet weak var taskStartDatePicker: UIDatePicker!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskDueDatePicker: UIDatePicker!
    @IBOutlet weak var taskSaveButton: UIButton!
    
    
    var tasks: [NSManagedObject] = []
    
    var selectedAssessment: Assessment?
    
    let dateFormatter = DateFormatter()
    
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.styleDate()
        let currentDate = Date()
        
        /// Makes sure the task start date is atleast 1 miniute from now
        /// Makes sure the task start date onlly goes upto the assessment due date
        var startDateComponent = DateComponents()
        startDateComponent.minute = 1
        let startDate = Calendar.current.date(byAdding: startDateComponent, to: currentDate)!
        let strStartDate = dateFormatter.string(from: startDate)
        taskStartDateLabel.text = strStartDate
        taskStartDatePicker.minimumDate = startDate
        taskStartDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        /// Makes sure the task due date is atleast 31 miniutes from now
        /// Makes sure the task due date onlly goes upto the assessment due date
        var dueDateComponent = DateComponents()
        dueDateComponent.minute = 31
        let dueDate = Calendar.current.date(byAdding: dueDateComponent, to: currentDate)!
        let strDueDate = dateFormatter.string(from: dueDate)
        taskDueDateLabel.text = strDueDate
        taskDueDatePicker.minimumDate = dueDate
        taskDueDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        /// Onload requests for calendar access for reminder functionality
        eventStore.requestAccess(to: .event, completion: {_,_ in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Saving new task data
    @IBAction func onSave(_ sender: Any) {
        
        /// Makes sure the needed input fields are not empty while creating a new Task entry
        if taskNameField.text?.isEmpty == false && taskNotesField.text?.isEmpty == false {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
            
            /// Initialization of a new Task Core Data Model Object
            let task = NSManagedObject(entity: entity, insertInto: managedContext)
            
            /// Setting atrribute values of the Task Object
            task.setValue(taskNameField.text!, forKeyPath: "taskName")
            task.setValue(taskNotesField.text!, forKeyPath: "taskNotes")
            task.setValue(taskReminderSwitch.isOn, forKeyPath: "taskDueReminder")
            task.setValue(taskCompletionSlider.value, forKeyPath: "taskCompletion")
            task.setValue(taskStartDatePicker.date, forKeyPath: "taskStartDate")
            task.setValue(taskDueDatePicker.date, forKeyPath: "taskDueDate")
            let reminderIdentifier = addToCalendar(calendarSwitch: taskReminderSwitch.isOn, taskName: taskNameField.text!, startDate: taskStartDatePicker.date, dueDate: taskDueDatePicker.date)
            task.setValue(reminderIdentifier, forKey: "taskReminderIdentifier")
            
            /// Creates a relationship between the selected Assessment Object and the newly created Task Object
            selectedAssessment?.addToTasks((task as? Task)!)
            

            do {
                /// Saving the created Task Object
                try managedContext.save()
                tasks.append(task)
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
        taskDueDatePicker.minimumDate = taskStartDatePicker.date + (30 * 60)
    }
    
    /// While scrolling due DatePicker updates the text due date value appropriately
    @IBAction func onDueDateChange(_ sender: Any) {
        let strDate = dateFormatter.string(from: taskDueDatePicker.date)
        taskDueDateLabel.text = strDate
        taskStartDatePicker.maximumDate = taskDueDatePicker.date - (30 * 60)
    }
    
}
