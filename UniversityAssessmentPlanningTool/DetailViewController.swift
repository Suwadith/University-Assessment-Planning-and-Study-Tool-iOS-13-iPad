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
    
    
    @IBOutlet weak var detailTableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO remove
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext;        // Do any additional setup after loading the view.
        configureView()
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = assessment {
            if let label = assessmentNameLabel {
                label.text = detail.assessmentName
            }
            
            
        }
        
//        autoSelectTableRow()
        
        //detailTableView?.reloadData()
    }

    var assessment: Assessment? {
        didSet {
            // Update the view.
            configureView()
            //detailTableView?.reloadData()
        }
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddNewTaskViewController
            controller.selectedAssessment = assessment
//            if let controller = segue.destination as? UIViewController {
//                controller.popoverPresentationController!.delegate = self
//                controller.preferredContentSize = CGSize(width: 320, height: 500)
//            }
            
        } else if segue.identifier == "editTask" {
        print("Edit")
        if let indexPath = detailTableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
            print(object.taskName!)
            let controller = (segue.destination as! UINavigationController).topViewController as! EditTaskViewController
            controller.task = object
            controller.selectedAssessment = assessment
        }
        
        
        
//        if segue.identifier == "editTask" {
//            if let indexPath = detailTableView.indexPathForSelectedRow {
//                let object = fetchedResultsController.object(at: indexPath)
//                let controller = (segue.destination as! UINavigationController).topViewController as! EditTaskViewController
//                controller. = object as Task
//                controller.task = selectedProject
//            }
//        }
    }
    }
    
    func configureCell(_ cell: TaskTableViewCell, withEvent task: Task, index: Int) {
        //        cell.textLabel!.text = assessment.asssessmentModuleName!
        cell.taskNameLabel.text = task.taskName
//        cell.assessmentNameLabel.text = assessment.assessmentName
//        cell.assessmentValueLabel.text = String(assessment.asssessmentValue)
//        cell.assessmentMarkLabel.text = String(assessment.asssessmentMarkAwarded)
//        cell.assessmentDueDateLabel.text = dateFormatter.string(from: assessment.asssessmentDueDate!)
    }
    
//    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
//        autoSelectTableRow()
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Detail Table View Cell", for: indexPath) as! TaskTableViewCell
        let task = fetchedResultsController.object(at: indexPath)
        print(task)
        cell.taskNameLabel?.text = task.taskName!
        
        //        configureCell(cell, withEvent: assessment)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        if assessment != nil {
            // Setting a predicate
            let predicate = NSPredicate(format: "%K == %@", "assessment", assessment!)
            //let predicate = NSPredicate(format: "taskName == 123")
           fetchRequest.predicate = predicate
        }
        
//        let predicate = NSPredicate(format: "taskName == 1234")
//        fetchRequest.predicate = predicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "taskName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-task")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
//        autoSelectTableRow()
        
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
        configureView()
        }
//        autoSelectTableRow()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailTableView.endUpdates()
    
    }
    
//    func autoSelectTableRow() {
//        let indexPath = IndexPath(row: 0, section: 0)
//        if detailTableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
//            detailTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
//
//            if let indexPath = detailTableView.indexPathForSelectedRow {
//                let object = fetchedResultsController.object(at: indexPath)
//                self.performSegue(withIdentifier: "showDetail", sender: object)
//            }
//        } else {
//            let empty = {}
//            self.performSegue(withIdentifier: "showDetail", sender: empty)
//
//        }
//    }
    

}

