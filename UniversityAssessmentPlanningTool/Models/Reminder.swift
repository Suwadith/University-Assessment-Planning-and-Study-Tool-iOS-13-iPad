//
//  Reminder.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/14/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import Foundation
import EventKit

class Reminder {
    
    /// Creates an Assesment reminder (Current Date is used as the reminder start date)
    func createEvent(title: String, date: Date) -> String{
        let eventStore:EKEventStore = EKEventStore()
        var identifier = ""
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if granted && error == nil {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = Date()
                event.endDate = date
                event.calendar = eventStore.defaultCalendarForNewEvents
    
                do {
                    try eventStore.save(event, span: .thisEvent)
                    identifier = event.eventIdentifier
                } catch let error as NSError {
                    print("error \(error)")
                }
                
            } else {
                print("error \(error)")
            }
            
        }
        sleep(1)
        return identifier
    }
    
    /// Creates a Task reminder
    func createTaskEvent(title: String, startDate: Date, dueDate: Date) -> String{
        let eventStore:EKEventStore = EKEventStore()
        var identifier = ""
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if granted && error == nil {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = dueDate
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    identifier = event.eventIdentifier
                } catch let error as NSError {
                    print("error \(error)")
                }
            } else {
                print("error \(error)")
            }
            
        }
        sleep(1)
        return identifier
    }
    
    /// Deletes a particular event by matching with the event identifier String
    func deleteEvent(eventIdentifier: String) -> Bool {
        var sucesss = false
        let eventStore:EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            if granted && error == nil {
                
                let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
                if eventToRemove != nil {
                    do {
                        try eventStore.remove(eventToRemove!, span: .thisEvent)
                        sucesss = true
                    } catch let error as NSError {
                        print("error \(error)")
                        sucesss = false
                    }
                }
            }
            
        }
        sleep(1)
        return sucesss
    }
    
}
