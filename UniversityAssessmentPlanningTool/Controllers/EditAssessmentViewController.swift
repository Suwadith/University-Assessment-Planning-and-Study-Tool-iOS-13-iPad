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
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.minute = 30
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        let strDate = dateFormatter.string(from: futureDate)
        selectedDueDateLable.text = strDate
        
        dueDatePicker.minimumDate = futureDate
        
        configureView()
        
        
        //        let date = Date()
        //        let strDate = dateFormatter.string(from: date)
        //        selectedDueDateLable.text = strDate
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
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
                if calendarSwitch.isOn {
//                    print(detail.assessmentReminderIdentifier!)
                }
            }
            if let marks = marksAwardedField {
                marks.text = String(detail.asssessmentMarkAwarded)
            }
            if let dueDateLabel = selectedDueDateLable {
                dueDateLabel.text = dateFormatter.string(from: detail.asssessmentDueDate!)
//                print(detail.asssessmentDueDate!)
            }
            if let dueDate = dueDatePicker {
                dueDate.date = detail.asssessmentDueDate!
            }
        }
    }
    
    
    var assessment: Assessment? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
    
    @IBAction func onUpdate(_ sender: Any) {
        if moduleNameField.text?.isEmpty == false && assessmentNameField.text?.isEmpty == false && valuePercentageField.text?.isEmpty == false
            && marksAwardedField.text?.isEmpty == false {
            
            if valuePercentageField.checkIfNumeric() != false && marksAwardedField.checkIfNumeric() != false {
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                // 1
                let managedContext = appDelegate.persistentContainer.viewContext
                
                // 2
                //        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Assessment")
                //
                //        fetchRequest.predicate = NSPredicate(format: "assessmentName = ", "")
                
                let object = assessment!
                
                // 3
                object.setValue(moduleNameField.text!, forKeyPath: "asssessmentModuleName")
                object.setValue(assessmentNameField.text!, forKeyPath: "assessmentName")
                object.setValue(Int(levelSegment.titleForSegment(at: levelSegment.selectedSegmentIndex)!), forKeyPath: "asssessmentLevel")
                object.setValue(Int(valuePercentageField.text!), forKeyPath: "asssessmentValue")
                object.setValue(notesField.text!, forKeyPath: "asssessmentNotes")
                object.setValue(addToCalendarSwitch.isOn, forKeyPath: "asssessmentDueReminder")
                object.setValue(Int(marksAwardedField.text!), forKeyPath: "asssessmentMarkAwarded")
                object.setValue(assessment?.assessmentStartDate, forKeyPath: "assessmentStartDate")
                object.setValue(dueDatePicker.date, forKeyPath: "asssessmentDueDate")
                
                
                
                //            print(reminderIdentifier)
                
                
                // 4
                do {
                    
                    //                print(object.assessmentReminderIdentifier!)
                    
                    if object.assessmentReminderIdentifier != "" {
                        let reminder = Reminder()
                        reminder.deleteEvent(eventIdentifier: object.assessmentReminderIdentifier!)
                        object.setValue("", forKey: "assessmentReminderIdentifier")
                    }
                    
                    //                sleep(1)
                    if addToCalendarSwitch.isOn {
                        let reminderIdentifier = addToCalendar(calendarSwitch: addToCalendarSwitch.isOn, assessmentName: assessmentNameField.text!, dueDate: dueDatePicker.date)
                        object.setValue(reminderIdentifier, forKey: "assessmentReminderIdentifier")
                    }
                    
                    try managedContext.save()
                    //                assessments.append(object)
                    dismissPopOver()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
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
