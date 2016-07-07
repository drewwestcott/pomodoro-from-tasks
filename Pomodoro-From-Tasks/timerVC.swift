//
//  timerVC.swift
//  Pomodoro-From-Tasks
//
//  Created by Drew Westcott on 06/07/2016.
//  Copyright © 2016 Drew Westcott. All rights reserved.
//

import UIKit
import EventKit


class timerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet weak var timerTableView: UITableView!
    
    let eventStore = EKEventStore()
    var reminders: [EKCalendar]?
    var Datasource = [Task]()
    
    override func viewDidLoad() {
        timerTableView.delegate = self
        timerTableView.dataSource = self
        needPermissionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCalendarAuthorisation()
    }

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
            print("------Access Denied")
            needPermissionView.fadeIn()
        case EKAuthorizationStatus.restricted:
            //Use has denied access
            print("------Access Restricted")
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
            self.timerTableView.reloadData()
        })
    }
    
    @IBAction func goToSettings(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared().openURL(openSettingsUrl! as URL)
    }
    
    func loadReminders() {
        //Think this is just reading in the Remainder Lists names
        reminders = eventStore.calendars(for: EKEntityType.reminder)
        
        let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [])
        eventStore.fetchReminders(matching: predicate) { tasks in
            print("-----------------------------------------------------")
            for task in tasks! {
                let saveTask = Task(title: task.title, priority: task.priority)
                if task.priority == 1 {
                    self.Datasource.append(saveTask)
                    print("Task Retrieved: \(task.title) \(task.priority) \(task.creationDate!)")
                }
                print("-----------------------------------------------------")

            }}
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timerTableView.dequeueReusableCell(withIdentifier: "timerCell") as? TimerCell
        
        let task = Datasource[indexPath.row]
        //cell?.configureTimerCell(task: task)
        cell?.timerTask.text = task.title
        cell?.timerCompletedTimes.text = "\(task.priority)"
        return cell!
    }

}
