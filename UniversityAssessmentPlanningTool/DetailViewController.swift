//
//  DetailViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/12/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var assessmentNameLabel: UILabel!
    @IBOutlet weak var assessmentNotesLabel: UILabel!
    @IBOutlet weak var assessmentCompletionBar: CircularProgressBar!
    @IBOutlet weak var assessmentDaysLeft: CircularProgressBar!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var editTaskButton: UIBarButtonItem!
    
    let calculations: Calculations = Calculations()
    let colours: Colours = Colours()
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let dateFormatter = DateFormatter()
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        configureView()
        
        /// By defaul the Edit Task button is disabled until one of the Assessments is chosen
        editTaskButton.isEnabled = false
    }
    
    /// Populates the  Assesment Overview Top Panel in the DetailView
    func configureView() {
        if let detail = assessment {
            if let assessmentName = assessmentNameLabel {
                assessmentName.text = detail.assessmentName
            }
            if let assessmentNotes = assessmentNotesLabel {
                assessmentNotes.text = detail.asssessmentNotes
            }
            
            let tasks = (detail.tasks!.allObjects as! [Task])
            let assessmentProgress = calculations.getAssessmentProgress(tasks)
            let daysLeftAsessment = calculations.getRemainingTimePercentage(detail.assessmentStartDate!, end: detail.asssessmentDueDate!)
            var daysRemaining = self.calculations.getDateDiff(currentDate, end: detail.asssessmentDueDate!)
            
            
            if daysRemaining < 0 {
                daysRemaining = 0
            }
            
            /// Overall Assessment Completion Cicular Progress Bar Generation
            DispatchQueue.main.async {
                let colours = self.colours.getProgressGradient(assessmentProgress)
                self.assessmentCompletionBar?.customSubtitle = "Completed"
                self.assessmentCompletionBar?.startGradientColor = colours[0]
                self.assessmentCompletionBar?.endGradientColor = colours[1]
                self.assessmentCompletionBar?.progress = CGFloat(assessmentProgress) / 100
            }
            
            /// Assessment Remaining Days Circular Progress Bar Generation
            DispatchQueue.main.async {
                let colours = self.colours.getProgressGradient(daysLeftAsessment, negative: true)
                self.assessmentDaysLeft?.customTitle = "\(daysRemaining)"
                self.assessmentDaysLeft?.customSubtitle = "Days Left"
                self.assessmentDaysLeft?.startGradientColor = colours[0]
                self.assessmentDaysLeft?.endGradientColor = colours[1]
                self.assessmentDaysLeft?.progress =  CGFloat(daysLeftAsessment) / 100
            }
        }
    }
    
    /// Populates the above overview panel using the selected Assessment Data (Object)
    var assessment: Assessment? {
        didSet {
            configureView()
        }
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /// Segue for creating new Task
        if segue.identifier == "addTask" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddNewTaskViewController
            controller.selectedAssessment = assessment
            
            /// Segue for populating edit Task form fields
        } else if segue.identifier == "editTask" {
            if let indexPath = detailTableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! EditTaskViewController
                controller.task = object
                controller.selectedAssessment = assessment
            }
            
        }
    }
    
    /// Creating individual cells of the Task table list
    func configureCell(_ cell: TaskTableViewCell, withEvent task: Task, index: Int) {
        cell.taskNumberLabel.text = "Task: " + String(index+1)
        cell.taskNameLabel.text = task.taskName
        cell.taskNotesLabel.text = task.taskNotes
        cell.taskDueDateLabel.text = "Due: " + setDueDateCell(date: task.taskDueDate!)
        cell.taskDaysLeftLabel.text = "Days Left: " + String(setDaysLeftLabelCell(date: task.taskDueDate!))
        cell.setBars(startDate: task.taskStartDate!, dueDate: task.taskDueDate!, completion: Int(task.taskCompletion))
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        /// Hiding detail view sections if No Assessment is chosen or No Assessment is Available (Displays a message too)
        if assessment == nil {
            assessmentNameLabel.isHidden = true
            assessmentNotesLabel.isHidden = true
            assessmentCompletionBar.isHidden = true
            assessmentDaysLeft.isHidden = true
            detailTableView.isEditing = true
            addTaskButton.isEnabled = false
            editTaskButton.isEnabled = false
            detailTableView.setEmptyMessage("Add a new Assessment to manage Tasks", UIColor.black)
            
        }else if sectionInfo.numberOfObjects == 0 {
            detailTableView.setEmptyMessage("No tasks available for this Assessment", UIColor.black)
        }
        
        return sectionInfo.numberOfObjects
    }
    
    /// Populating Task list of cells using custom TaskTableViewCell cass
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Detail Table View Cell", for: indexPath) as! TaskTableViewCell
        let task = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: task, index: indexPath.row)
        return cell
    }
    
    /// After deleting a Task updates the Core Data Storage
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// Fetching Task Results
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        /// Fetch Size
        fetchRequest.fetchBatchSize = 20
        
        /// Fetching the tasks relevant to the selected Assessment
        if assessment != nil {
            let predicate = NSPredicate(format: "%K == %@", "assessment", assessment!)
            fetchRequest.predicate = predicate
        }
        
        /// Sorting key
        let sortDescriptor = NSSortDescriptor(key: "taskDueDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-task")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            detailTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            detailTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            detailTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            detailTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(detailTableView.cellForRow(at: indexPath!)! as! TaskTableViewCell, withEvent: anObject as! Task, index: indexPath!.row)
        case .move:
            configureCell(detailTableView.cellForRow(at: indexPath!)! as! TaskTableViewCell, withEvent: anObject as! Task, index: indexPath!.row)
            detailTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        configureView()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailTableView.endUpdates()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTaskButton.isEnabled = true
    }
    
    /// Date Stying YYYY-MM-DD
    func setDueDateCell(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /// Calculating days left
    func setDaysLeftLabelCell(date: Date) -> Int {
        var daysLeft = Calendar.current.dateComponents([.day], from: currentDate, to: date).day!
        if daysLeft < 0 {
            daysLeft = 0
        }
        return daysLeft
    }
    
    /// On call selects a Task cell autmatically (If available)
    func autoSelectTableRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if detailTableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            detailTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = detailTableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showDetail", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showDetail", sender: empty)
            
        }
    }
}

