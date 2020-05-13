//
//  AddNewAssessmentViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/13/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData

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
    
    var assessments: [NSManagedObject] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let date = Date()

        let strDate = dateFormatter.string(from: date)
        selectedDueDateLable.text = strDate

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSave(_ sender: Any) {
         guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         
         // 1
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         // 2
         let entity =
           NSEntityDescription.entity(forEntityName: "Assessment",
                                      in: managedContext)!
         
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
        assessment.setValue(dueDatePicker.date, forKeyPath: "asssessmentDueDate")
         
         // 4
         do {
           try managedContext.save()
           assessments.append(assessment)
         } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
    }
    
    
    @IBAction func onDateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

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
