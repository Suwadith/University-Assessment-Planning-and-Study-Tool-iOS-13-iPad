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

        // Do any additional setup after loading the view.
        
        dateFormatter.styleDate()
        
        let currentDate = Date()
        
        var startDateComponent = DateComponents()
        startDateComponent.minute = 30


        taskStartDatePicker.minimumDate = task?.taskStartDate
        taskStartDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        var dueDateComponent = DateComponents()
        dueDateComponent.minute = 60
        let dueDate = Calendar.current.date(byAdding: dueDateComponent, to: currentDate)!


        taskDueDatePicker.minimumDate = dueDate
        taskDueDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
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
    
    
    
    @IBAction func onUpdate(_ sender: Any) {
        if taskNameField.text?.isEmpty == false && taskNotesField.text?.isEmpty == false {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            // 1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let object = task!
            
            // 3
            object.setValue(taskNameField.text!, forKeyPath: "taskName")
            object.setValue(taskNotesField.text!, forKeyPath: "taskNotes")
            object.setValue(taskReminderSwitch.isOn, forKeyPath: "taskDueReminder")
            object.setValue(taskCompletionSlider.value, forKeyPath: "taskCompletion")
            object.setValue(taskStartDatePicker.date, forKeyPath: "taskStartDate")
            object.setValue(taskDueDatePicker.date, forKeyPath: "taskDueDate")
            
            do {
                    
                print(object.taskDueReminder)
                
                if object.taskReminderIdentifier != "" {
                    let reminder = Reminder()
                    reminder.deleteEvent(eventIdentifier: object.taskReminderIdentifier!)
                    object.setValue("", forKey: "taskReminderIdentifier")
                }
                    
                    
                    //                sleep(1)
                    if taskReminderSwitch.isOn {
                        let reminderIdentifier = addToCalendar(calendarSwitch: taskReminderSwitch.isOn, taskName: taskNameField.text!, startDate: taskStartDatePicker.date, dueDate: taskDueDatePicker.date)
                        object.setValue(reminderIdentifier, forKey: "taskReminderIdentifier")
                    }
                    
                    try managedContext.save()
                    //                assessments.append(object)
                    dismissPopOver()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                showAlert(title: "Error", msg: "Only the notes field can be left empty")
            }
        
        
    }
    
    func addToCalendar(calendarSwitch: Bool, taskName: String, startDate: Date, dueDate: Date) -> String {
            var reminderIdentifier = ""
            if calendarSwitch {
                let reminder = Reminder()
                reminderIdentifier = reminder.createTaskEvent(title: taskName, startDate: startDate, dueDate: dueDate)
    //            print(reminderIdentifier)
            }
            return reminderIdentifier
        }
    
    @IBAction func onSliderChange(_ sender: UISlider) {
        taskCompletionLabel.text = String(Int(sender.value)) + "% Completed"
    }
    
    @IBAction func onStartDateChange(_ sender: Any) {
        
        let strDate = dateFormatter.string(from: taskStartDatePicker.date)
        taskStartDateLabel.text = strDate
    }
    
    @IBAction func onDueDateChange(_ sender: Any) {
        
        let strDate = dateFormatter.string(from: taskDueDatePicker.date)
        taskDueDateLabel.text = strDate
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
