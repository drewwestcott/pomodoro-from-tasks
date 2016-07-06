//
//  timerVC.swift
//  Pomodoro-From-Tasks
//
//  Created by Drew Westcott on 06/07/2016.
//  Copyright © 2016 Drew Westcott. All rights reserved.
//

import UIKit
import EventKit


class timerVC: UIViewController {
    
    @IBOutlet weak var needPermissionView: UIView!
    
    let eventStore = EKEventStore()
    var reminders: [EKCalendar]?
    var Datasource = [Task]()

    func checkCalendarAuthorisation() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        print(status)
        
        switch(status) {
        case EKAuthorizationStatus.notDetermined:
            //usually only first run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            //We have access
            print("------We have access")
            DispatchQueue.main.async(execute: {
                self.loadReminders()
            })
        case EKAuthorizationStatus.denied:
            //Use has denied access
            needPermissionView.fadeIn()
        case EKAuthorizationStatus.restricted:
            //Use has denied access
            needPermissionView.fadeIn()
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadReminders()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.needPermissionView.fadeIn()
                })
            }
        })
    }
    
    func loadReminders() {
        //Think this is just reading in the Remainder Lists names
        reminders = eventStore.calendars(for: EKEntityType.reminder)
        
        let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [])
        eventStore.fetchReminders(matching: predicate) { tasks in
            for task in tasks! {
                let saveTask = Task(title: task.title, priority: task.priority)
                if task.priority == 1 {
                    self.Datasource.append(saveTask)
                    print("\(task.title) \(task.priority) \(task.creationDate)")
                }
            }}
        
    }

}