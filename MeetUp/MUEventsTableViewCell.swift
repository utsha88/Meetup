//
//  MUEventsTableViewCell.swift
//  MeetUp
//
//  Created by Utsha Guha on 24-1-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit

class MUEventsTableViewCell: UITableViewCell {
    @IBOutlet var eventName:UILabel?
    @IBOutlet var eventGroup:UILabel?
    @IBOutlet var eventDateTime:UILabel?
    @IBOutlet var eventRsvpNum:UILabel?
    @IBOutlet var eventFavourite:UIButton?
    
    @IBAction func pressFavouriteButton(sender: UIButton){
        if sender.tag == 0 {
            sender.tag = 1
        }
        else{
            sender.tag = 0
        }
    }
}
