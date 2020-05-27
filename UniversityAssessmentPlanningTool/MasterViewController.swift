//
//  MasterViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/12/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit
import CoreData


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var editAssessmentButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.styleDate()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        /// By defaul the Edit Assessment button is disabled until one of the Assessments is chosen
        editAssessmentButton.isEnabled = false
        autoSelectTableRow()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoSelectTableRow()
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /// Retreives all the Assessment data from the COre Data persistant storage
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Assessment")
        do {
            let assessments = try managedContext.fetch(fetchRequest)
            for assessment in assessments as! [Assessment] {
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /// Segue for loading detail view with the selected Assessment details (Object)
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.assessment = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                detailViewController = controller
            }
            
            /// Segue for edit Assessment popup
        } else if segue.identifier == "editAssessment" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! EditAssessmentViewController
                controller.assessment = object
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    /// Populating Assesment list of cells using custom AssessmentTableViewCell cass
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Master Table View Cell", for: indexPath) as! AssessmentTableViewCell
        let assessment = fetchedResultsController.object(at: indexPath)
        cell.assessmentModuleNameLable?.text = assessment.asssessmentModuleName!
        cell.assessmentNameLabel?.text = assessment.assessmentName!
        cell.assessmentValueLabel?.text = String(assessment.asssessmentValue) + "%"
        cell.assessmentMarkLabel?.text = String(assessment.asssessmentMarkAwarded) + "%"
        dateFormatter.dateFormat = "MMM d, yyyy"
        cell.assessmentDueDateLabel?.text = dateFormatter.string(from: assessment.asssessmentDueDate!)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        autoSelectTableRow()
    }
    
    /// Upon selecting an Assessment, enables the edit button
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editAssessmentButton.isEnabled = true
    }
    
    /// After deleting an Assessment updates the Core Data Storage
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    /// Creating individual cells of the Assessmnt table list
    func configureCell(_ cell: AssessmentTableViewCell, withEvent assessment: Assessment) {
        cell.assessmentModuleNameLable.text = assessment.asssessmentModuleName
        cell.assessmentNameLabel.text = assessment.assessmentName
        cell.assessmentValueLabel.text = String(assessment.asssessmentValue)
        cell.assessmentMarkLabel.text = String(assessment.asssessmentMarkAwarded)
        cell.assessmentDueDateLabel.text = dateFormatter.string(from: assessment.asssessmentDueDate!)
    }
    
    // MARK: - Fetched results controller
    
    /// Fetching Assessment Results
    var fetchedResultsController: NSFetchedResultsController<Assessment> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Assessment> = Assessment.fetchRequest()
        
        /// Fetch Size
        fetchRequest.fetchBatchSize = 20
        
        /// Sorting key
        let sortDescriptor = NSSortDescriptor(key: "asssessmentModuleName", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        autoSelectTableRow()
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Assessment>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! AssessmentTableViewCell, withEvent: anObject as! Assessment)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! AssessmentTableViewCell, withEvent: anObject as! Assessment)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
        autoSelectTableRow()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        autoSelectTableRow()
    }
    
    /// On call selects an Assessment cell autmatically (If available)
    func autoSelectTableRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showDetail", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showDetail", sender: empty)
            
        }
    }
    
}

