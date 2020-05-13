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
        let date = Date()
        let strDate = dateFormatter.string(from: date)
        selectedDueDateLable.text = strDate
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onEdit(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Assessment")
        
        fetchRequest.predicate = NSPredicate(format: "assessmentName = ", "")
        
        // 3
//        assessment.setValue(moduleNameField.text!, forKeyPath: "asssessmentModuleName")
//        assessment.setValue(assessmentNameField.text!, forKeyPath: "assessmentName")
//        assessment.setValue(Int(levelSegment.titleForSegment(at: levelSegment.selectedSegmentIndex)!), forKeyPath: "asssessmentLevel")
//        assessment.setValue(Int(valuePercentageField.text!), forKeyPath: "asssessmentValue")
//        assessment.setValue(notesField.text!, forKeyPath: "asssessmentNotes")
//        assessment.setValue(addToCalendarSwitch.isOn, forKeyPath: "asssessmentDueReminder")
//        assessment.setValue(Int(marksAwardedField.text!), forKeyPath: "asssessmentMarkAwarded")
//        assessment.setValue(dueDatePicker.date, forKeyPath: "asssessmentDueDate")
        
        // 4
//        do {
//            try managedContext.save()
//            assessments.append(assessment)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
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
