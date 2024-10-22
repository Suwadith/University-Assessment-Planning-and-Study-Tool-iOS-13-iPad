//
//  AddNewAssessmentViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/13/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddNewAssessmentViewController: UIViewController {
    
    @IBOutlet weak var moduleNameField: UITextField!
    @IBOutlet weak var assessmentNameField: UITextField!
    @IBOutlet weak var levelSegment: UISegmentedControl!
    @IBOutlet weak var valuePercentageField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var marksAwardedField: UITextField!
    @IBOutlet weak var selectedDueDateLable: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var saveAssessmentButton: UIButton!
    
    let currentDate = Date()
    
    var assessments: [NSManagedObject] = []
    
    let dateFormatter = DateFormatter()
    
    let eventStore = EKEventStore()
    
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
        
        /// Onload requests for calendar access for reminder functionality
        eventStore.requestAccess(to: .event, completion: {_,_ in })
        
        /// Hides the keyboard when tapped outside of the create new assessment window
        hideKeyboardWhenTappedAround()
    }
    
    /// Saving new assessment data
    @IBAction func onSave(_ sender: Any) {
        
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
                    
                    let entity = NSEntityDescription.entity(forEntityName: "Assessment", in: managedContext)!
                    
                    /// Initialization of a new Assessment Core Data Model Object
                    let assessment = NSManagedObject(entity: entity, insertInto: managedContext)
                    
                    /// Setting atrribute values of the Assessment Object
                    assessment.setValue(moduleNameField.text!, forKeyPath: "asssessmentModuleName")
                    assessment.setValue(assessmentNameField.text!, forKeyPath: "assessmentName")
                    assessment.setValue(Int(levelSegment.titleForSegment(at: levelSegment.selectedSegmentIndex)!), forKeyPath: "asssessmentLevel")
                    assessment.setValue(Int(valuePercentageField.text!), forKeyPath: "asssessmentValue")
                    assessment.setValue(notesField.text!, forKeyPath: "asssessmentNotes")
                    assessment.setValue(addToCalendarSwitch.isOn, forKeyPath: "asssessmentDueReminder")
                    assessment.setValue(Int(marksAwardedField.text!), forKeyPath: "asssessmentMarkAwarded")
                    assessment.setValue(currentDate, forKeyPath: "assessmentStartDate")
                    assessment.setValue(dueDatePicker.date, forKeyPath: "asssessmentDueDate")
                    let reminderIdentifier = addToCalendar(calendarSwitch: addToCalendarSwitch.isOn, assessmentName: assessmentNameField.text!, dueDate: dueDatePicker.date)
                    assessment.setValue(reminderIdentifier, forKey: "assessmentReminderIdentifier")
                    
                    do {
                        /// Saving the created Assessment Object
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
