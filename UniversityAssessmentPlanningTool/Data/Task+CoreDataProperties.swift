//
//  Task+CoreDataProperties.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/16/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var taskCompletion: Int16
    @NSManaged public var taskDueDate: Date?
    @NSManaged public var taskDueReminder: Bool
    @NSManaged public var taskName: String?
    @NSManaged public var taskNotes: String?
    @NSManaged public var taskStartDate: Date?
    @NSManaged public var taskReminderIdentifier: String?
    @NSManaged public var assessment: Assessment?

}
