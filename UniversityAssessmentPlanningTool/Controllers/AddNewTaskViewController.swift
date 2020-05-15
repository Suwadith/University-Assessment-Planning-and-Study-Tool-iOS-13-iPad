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
        
        // Do any additional setup after loading the view.
        
        dateFormatter.styleDate()
        
        let currentDate = Date()
        
        var startDateComponent = DateComponents()
        startDateComponent.minute = 30
        let startDate = Calendar.current.date(byAdding: startDateComponent, to: currentDate)!
        let strStartDate = dateFormatter.string(from: startDate)
        taskStartDateLabel.text = strStartDate
        taskStartDatePicker.minimumDate = startDate
        taskStartDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        var dueDateComponent = DateComponents()
        dueDateComponent.minute = 60
        let dueDate = Calendar.current.date(byAdding: dueDateComponent, to: currentDate)!
        let strDueDate = dateFormatter.string(from: dueDate)
        taskDueDateLabel.text = strDueDate
        taskDueDatePicker.minimumDate = dueDate
        taskDueDatePicker.maximumDate = selectedAssessment?.asssessmentDueDate
        
        eventStore.requestAccess(to: .event, completion: {_,_ in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func onSave(_ sender: Any) {
        if taskNameField.text?.isEmpty == false && taskNotesField.text?.isEmpty == false {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            // 1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
            
            let task = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
            
            // 3
            task.setValue(taskNameField.text!, forKeyPath: "taskName")
            task.setValue(taskNotesField.text!, forKeyPath: "taskNotes")
            task.setValue(taskReminderSwitch.isOn, forKeyPath: "taskDueReminder")
            task.setValue(taskCompletionSlider.value, forKeyPath: "taskCompletion")
            task.setValue(taskStartDatePicker.date, forKeyPath: "taskStartDate")
            task.setValue(taskDueDatePicker.date, forKeyPath: "taskDueDate")
           
//            let reminderIdentifier = addToCalendar(calendarSwitch: taskReminderSwitch.isOn, taskName: taskNameField.text!, startDate: taskStartDatePicker.date, dueDate: taskDueDatePicker.date)
//            //            print(reminderIdentifier)
//            task.setValue(reminderIdentifier, forKey: "taskDueReminder")
            selectedAssessment?.addToTasks((task as? Task)!)
            
            // 4
            do {
                try managedContext.save()
                                tasks.append(task)
                print(task)
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
    
}
