//
//  TimerCell.swift
//  Pomodoro-From-Tasks
//
//  Created by Drew Westcott on 06/07/2016.
//  Copyright © 2016 Drew Westcott. All rights reserved.
//

import UIKit

class TimerCell: UITableViewCell {
    
    @IBOutlet weak var timerTask: UILabel!
    @IBOutlet weak var timerCompletedTimes: UILabel!
    
    func configureTimerCell(task: Task) {
        timerTask.text = task.title
        timerCompletedTimes.text = "0"
    }
}
