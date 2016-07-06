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
            
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timersButtonPressed(sender: UIButton!) {
        performSegue(withIdentifier: "timersSegue", sender: nil)
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

}
