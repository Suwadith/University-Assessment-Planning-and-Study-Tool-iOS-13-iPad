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
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.minute = 30
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        let strDate = dateFormatter.string(from: futureDate)
        selectedDueDateLable.text = strDate
        
        dueDatePicker.minimumDate = futureDate
        

        eventStore.requestAccess(to: .event, completion: {_,_ in })
    

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSave(_ sender: Any) {
        
        if moduleNameField.text?.isEmpty == false && assessmentNameField.text?.isEmpty == false && valuePercentageField.text?.isEmpty == false
        && marksAwardedField.text?.isEmpty == false {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            // 1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2
            let entity = NSEntityDescription.entity(forEntityName: "Assessment", in: managedContext)!
            
            let assessment = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
            
            // 3
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
//            print(reminderIdentifier)
            assessment.setValue(reminderIdentifier, forKey: "assessmentReminderIdentifier")
            
            
            // 4
            do {
                try managedContext.save()
//                assessments.append(assessment)
//                print(assessment)
                dismissPopOver()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            showAlert(title: "Error", msg: "Only the notes field can be left empty")
        }
        
        
    }
    
    func addToCalendar(calendarSwitch: Bool, assessmentName: String, dueDate: Date) -> String {
        var reminderIdentifier = ""
        if calendarSwitch {
            let reminder = Reminder()
            reminderIdentifier = reminder.createEvent(title: assessmentName, date: dueDate)
//            print(reminderIdentifier)
        }
        return reminderIdentifier
    }
    
    
    @IBAction func onDateChange(_ sender: Any) {
        
        let strDate = dateFormatter.string(from: dueDatePicker.date)
        selectedDueDateLable.text = strDate
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
