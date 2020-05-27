//
//  EditAssessmentViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/14/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData

class EditAssessmentViewController: UIViewController {
    
    @IBOutlet weak var moduleNameField: UITextField!
    @IBOutlet weak var assessmentNameField: UITextField!
    @IBOutlet weak var levelSegment: UISegmentedControl!
    @IBOutlet weak var valuePercentageField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var marksAwardedField: UITextField!
    @IBOutlet weak var selectedDueDateLable: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var updateAssessmentButton: UIButton!
    
    var assessments: [NSManagedObject] = []
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.styleDate()
        
        /// Makes sure the assessment due date is atleast 30 miniutes from now
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.minute = 30
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        let strDate = dateFormatter.string(from: futureDate)
        selectedDueDateLable.text = strDate
        dueDatePicker.minimumDate = futureDate
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Populates the Assessment cells according to their relevant attributes
    func configureView() {
        if let detail = assessment {
            if let moduleName = moduleNameField {
                moduleName.text = detail.asssessmentModuleName
            }
            if let assessmentName = assessmentNameField {
                assessmentName.text = detail.assessmentName
            }
            if let level = levelSegment {
                level.selectedSegmentIndex = Int(detail.asssessmentLevel)-3
            }
            if let valuePercentage = valuePercentageField {
                valuePercentage.text = String(detail.asssessmentValue)
            }
            if let notes = notesField {
                notes.text = detail.asssessmentNotes
            }
            if let calendarSwitch = addToCalendarSwitch {
                calendarSwitch.isOn = detail.asssessmentDueReminder
            }
            if let marks = marksAwardedField {
                marks.text = String(detail.asssessmentMarkAwarded)
            }
            if let dueDateLabel = selectedDueDateLable {
                dueDateLabel.text = dateFormatter.string(from: detail.asssessmentDueDate!)
            }
            if let dueDate = dueDatePicker {
                dueDate.date = detail.asssessmentDueDate!
            }
        }
    }
    
    /// Populates the Assessment cells if assessment data is available within the core data DB
    var assessment: Assessment? {
        didSet {
            configureView()
        }
    }
    
    
    /// Editing assessment data
    @IBAction func onUpdate(_ sender: Any) {
        
        /// Makes sure the needed input fields are not empty while creating a new Assessment entry
        if moduleNameField.text?.isEmpty == false && assessmentNameField.text?.isEmpty == false && valuePercentageField.text?.isEmpty == false
            && marksAwardedField.text?.isEmpty == false {
            
            /// Makes sure the number related input fields are not holding irrelavant characters
            if valuePercentageField.checkIfNumeric() != false && marksAwardedField.checkIfNumeric() != false {
                
                /// Makes sure the input values are within the range of 0-100
                if valuePercentageField.checkIfMakrsWithinRange() != false && marksAwardedField.checkIfMakrsWithinRange() != false {
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    
                    let managedContext = appDelegate.persistentContainer.viewContext
                    
                    /// Copies the selected Assessment Object
                    let object = assessment!
                    
                    /// Updates the copied object with the new edited Assessment field values
                    object.setValue(moduleNameField.text!, forKeyPath: "asssessmentModuleName")
                    object.setValue(assessmentNameField.text!, forKeyPath: "assessmentName")
                    object.setValue(Int(levelSegment.titleForSegment(at: levelSegment.selectedSegmentIndex)!), forKeyPath: "asssessmentLevel")
                    object.setValue(Int(valuePercentageField.text!), forKeyPath: "asssessmentValue")
                    object.setValue(notesField.text!, forKeyPath: "asssessmentNotes")
                    object.setValue(addToCalendarSwitch.isOn, forKeyPath: "asssessmentDueReminder")
                    object.setValue(Int(marksAwardedField.text!), forKeyPath: "asssessmentMarkAwarded")
                    object.setValue(assessment?.assessmentStartDate, forKeyPath: "assessmentStartDate")
                    object.setValue(dueDatePicker.date, forKeyPath: "asssessmentDueDate")
                    
                    do {
                        /// Checks if the Assessment has already been added to the calender and deletes if it already does
                        if object.assessmentReminderIdentifier != "" {
                            let reminder = Reminder()
                            reminder.deleteEvent(eventIdentifier: object.assessmentReminderIdentifier!)
                            object.setValue("", forKey: "assessmentReminderIdentifier")
                        }
                        
                        /// If reminder option is choosen then the new reminder date is added to the calendar
                        if addToCalendarSwitch.isOn {
                            let reminderIdentifier = addToCalendar(calendarSwitch: addToCalendarSwitch.isOn, assessmentName: assessmentNameField.text!, dueDate: dueDatePicker.date)
                            object.setValue(reminderIdentifier, forKey: "assessmentReminderIdentifier")
                        }
                        
                        /// Saves the modified Assessment Object
                        try managedContext.save()
                        dismissPopOver()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                } else {
                    showAlert(title: "Error", msg: "Value and Marks cannot be below 0 or more than 100")
                }
            } else {
                showAlert(title: "Error", msg: "Only nmeric values allowed in value and marks fields")
            }
        } else {
            showAlert(title: "Error", msg: "Only the notes field can be left empty")
        }
    }
    
    
//    @IBAction func onDelete(_ sender: Any) {
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let object = assessment!
//
//        do {
//
//            if object.assessmentReminderIdentifier != "" {
//                let reminder = Reminder()
//                reminder.deleteEvent(eventIdentifier: object.assessmentReminderIdentifier!)
//            }
//
//            managedContext.delete(object)
//            try managedContext.save()
//            
//            dismissPopOver()
//        }catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//
//    }
    
    /// Saves a reminder if the user chooses the option
    func addToCalendar(calendarSwitch: Bool, assessmentName: String, dueDate: Date) -> String {
        var reminderIdentifier = ""
        if calendarSwitch {
            let reminder = Reminder()
            reminderIdentifier = reminder.createEvent(title: assessmentName, date: dueDate)
        }
        return reminderIdentifier
    }
    
    /// While scrolling DatePicker updates the text date value appropriately
    @IBAction func onDateChange(_ sender: Any) {
        let strDate = dateFormatter.string(from: dueDatePicker.date)
        selectedDueDateLable.text = strDate
    }
    
}
