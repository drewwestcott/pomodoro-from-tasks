//
//  ViewController.swift
//  Pomodoro-From-Tasks
//
//  Created by Drew Westcott on 04/07/2016.
//  Copyright © 2016 Drew Westcott. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import EventKit

class ViewController: UIViewController {
    
    let eventStore = EKEventStore()
    var reminders: [EKCalendar]?
    
    var Datasource = [Task]()
    
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        checkCalendarAuthorisation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        print("login pressed")
        FIRAuth.auth()?.signIn(withEmail: "\(loginEmail.text)", password: "\(loginPassword.text)") { (user, error) in
            if error != nil {
                if let errorCode = FIRAuthErrorCode(rawValue: (error?.code)!) {
                    if errorCode == .errorCodeUserNotFound {
                        FIRAuth.auth()?.createUser(withEmail: "\(self.loginEmail)", password: "\(self.loginPassword)", completion: { (result, error) in
                            if error != nil {
                                print("Could not create account.")
                            } else {
                                if let uid = result?.uid {
                                    //Actually sign in here
                                    print("UID: \(uid)")
                                    FIRAuth.auth()?.signIn(withEmail: "\(self.loginEmail)", password: "\(self.loginPassword)", completion: { (authData, error) in
                                        
                                        if error != nil {
                                            print("oops something happened")
                                        } else {
                                            print("Signed in")
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
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
            print("There are \(Datasource.count) High Priority Reminders!")
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
                    print("\(task.title) \(task.priority)")
                }
            }}

    }
}
