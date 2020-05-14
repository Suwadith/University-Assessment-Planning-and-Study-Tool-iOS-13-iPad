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
    
    var assessmentTitle: String
    var date: Date
    var identifier: String
    
    
    init(title: String, date: Date) {
        self.assessmentTitle = title
        self.date = date
        self.identifier = ""
    }
    
    func createEvent() -> String{
        let eventStore:EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if granted && error == nil {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = self.assessmentTitle
                event.startDate = Date()
                event.endDate = self.date
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    self.identifier = event.eventIdentifier
                } catch let error as NSError {
                    print("error \(error)")
                }
                print("Save Event")
                
            } else {
                print("error \(error)")
            }
            
        }
        return self.identifier
    }
    
}
