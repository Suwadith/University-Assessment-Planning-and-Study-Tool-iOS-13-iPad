//
//  Assessment+CoreDataProperties.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/15/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//
//

import Foundation
import CoreData


extension Assessment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assessment> {
        return NSFetchRequest<Assessment>(entityName: "Assessment")
    }

    @NSManaged public var assessmentName: String?
    @NSManaged public var assessmentReminderIdentifier: String?
    @NSManaged public var asssessmentDueDate: Date?
    @NSManaged public var asssessmentDueReminder: Bool
    @NSManaged public var asssessmentLevel: Int16
    @NSManaged public var asssessmentMarkAwarded: Int16
    @NSManaged public var asssessmentModuleName: String?
    @NSManaged public var asssessmentNotes: String?
    @NSManaged public var asssessmentValue: Int16
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension Assessment {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
