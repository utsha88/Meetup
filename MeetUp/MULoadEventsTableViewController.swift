//
//  MULoadEventsTableViewController.swift
//  MeetUp
//
//  Created by Utsha Guha on 24-1-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit

/*******************    String Constants    ****************************/
struct Constants {
    static let MUFindEventURL           = "https://api.meetup.com/find/events?key=6752511f3291b2b182ee4d2ef312"
    static let MUNameKey                = "name"
    static let MUGroupKey               = "group"
    
    static let MUJSONEventDateKey       = "local_date"
    static let MUJSONEventTimeKey       = "local_time"
    static let MUJSONRSVPCountKey       = "yes_rsvp_count"
    static let MUJSONIdKey              = "id"
    
    static let MUEventNameKey           = "eventName"
    static let MUEventDateKey           = "eventDate"
    static let MUEventTimeKey           = "eventTime"
    static let MUEventGroupKey          = "eventGroup"
    static let MUEventRSVPKey           = "eventRSVPCount"
    static let MUEventIdKey             = "eventId"
    
    static let MUDefaultStringKey       = "TBD"
    
    static let MUFavImageKey            = "fav_check.png"
    static let MUUnFavImageKey          = "fav_uncheck.png"
    
    static let MUFavouriteEventsKey     = "favouriteEvents"
    static let MUEventCellIdentifier    = "eventIdentifier"
}
/***********************************************************************/

class MULoadEventsTableViewController: UITableViewController {
    var eventsArray:[Any] = []
    var favEventArray:[Any] = []
    
    override func viewDidLoad() {
        self.loadEvents()
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
    }
    
    /***********************************************************************/
    
            // Method Name: loadEvents()
            // Method Description: Firing /find/events API method to call all the events
    
    /***********************************************************************/
    func loadEvents(){
        let urlString = Constants.MUFindEventURL
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let _ = data {
                let responseArray = try? JSONSerialization.jsonObject(with: data!, options: []) as! [Any]
                for respDict in responseArray!{
                    var responseDict:[String:Any] = respDict as! [String : Any]
                    let eventId = responseDict[Constants.MUJSONIdKey]
                    let eventName = responseDict[Constants.MUNameKey]
                    let group:[String:Any] = responseDict[Constants.MUGroupKey] as! [String : Any]
                    let groupName = group[Constants.MUNameKey]
                    let eventDate = responseDict[Constants.MUJSONEventDateKey]
                    let eventTime = responseDict[Constants.MUJSONEventTimeKey]
                    let rsvpCount = String(describing: responseDict[Constants.MUJSONRSVPCountKey]!)
                // Adding only the required Event information into an Array
                self.eventsArray.append([Constants.MUEventIdKey:eventId ?? arc4random(),Constants.MUEventNameKey:eventName ?? Constants.MUDefaultStringKey,Constants.MUEventGroupKey:groupName ?? Constants.MUDefaultStringKey,Constants.MUEventDateKey:eventDate ?? Constants.MUDefaultStringKey,Constants.MUEventTimeKey:eventTime ?? Constants.MUDefaultStringKey,Constants.MUEventRSVPKey:rsvpCount])
                }
                // Call the datasource method once the fetch event activity is over.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        task.resume()
    }
    /***********************************************************************/
    
    /***********************************************************************/
    
    // Method Name: pressFavButton(sender: UIButton)
    // Method Description: Favourite button action method
    
    /***********************************************************************/
    @IBAction func pressFavButton(sender: UIButton){
        if let myButtonImage = sender.image(for: .normal),
            let buttonAppuyerImage = UIImage(named: Constants.MUUnFavImageKey),
            UIImagePNGRepresentation(myButtonImage) == UIImagePNGRepresentation(buttonAppuyerImage)
        {
            // Checking Favourite
            sender.setImage(UIImage(named: Constants.MUFavImageKey), for: UIControlState.normal)
            let tableViewCell:MUEventsTableViewCell = sender.superview?.superview as! MUEventsTableViewCell
            var eventIndexPath:IndexPath = tableView .indexPath(for: tableViewCell)!
            let selectedEvent = eventsArray[eventIndexPath.row] as! [String:String]
            let eventId = selectedEvent[Constants.MUEventIdKey]!
            favEventArray.append(eventId)
        } else {
            // Unchecking Favourite
            sender.setImage(UIImage(named: Constants.MUUnFavImageKey), for: UIControlState.normal)
            let tableViewCell:MUEventsTableViewCell = sender.superview?.superview as! MUEventsTableViewCell
            var eventIndexPath:IndexPath = tableView .indexPath(for: tableViewCell)!
            let selectedEvent = eventsArray[eventIndexPath.row] as! [String:String]
            for i in 0..<favEventArray.count {
                let favEvent:String = favEventArray[i] as! String
                 if favEvent == selectedEvent[Constants.MUEventIdKey]  {
                    favEventArray.remove(at: i)
                    break
                }
            }
        }
        // Storing locally the Favourite Event Ids
        UserDefaults.standard.set(favEventArray, forKey: Constants.MUFavouriteEventsKey)
    }
    /***********************************************************************/
    
    /***********************************************************************/
    
    // Method Description: Table View Datasource methods
    
    /***********************************************************************/
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MUEventsTableViewCell = tableView .dequeueReusableCell(withIdentifier: Constants.MUEventCellIdentifier, for: indexPath) as! MUEventsTableViewCell
        var event:[String:Any] = self.eventsArray[indexPath.row] as! [String : Any]
        var eventDate:String?
        var eventTime:String?
        var eventRsvpCount:String?
        eventDate = event[Constants.MUEventDateKey] as! String?
        eventTime = event[Constants.MUEventTimeKey] as! String?

        eventRsvpCount =  event[Constants.MUEventRSVPKey] as! String?

        let eventDateTime = eventDate! + ", " + eventTime!

        let eventId = event[Constants.MUEventIdKey] as! String?
        // Reading the locally stored Favourite Event Ids
        favEventArray = UserDefaults.standard.array(forKey: Constants.MUFavouriteEventsKey)!
        let isFavourite = favEventArray.contains { element in
            if case eventId! = String(describing: element) {
                return true
            }
            else{
                return false
            }
        }
        
        // Drawing the cell
        if isFavourite {
            cell.eventFavourite?.setImage(UIImage(named: Constants.MUFavImageKey), for: UIControlState.normal)
        }
        else{
            cell.eventFavourite?.setImage(UIImage(named: Constants.MUUnFavImageKey), for: UIControlState.normal)
        }
        
        cell.eventName?.text = event[Constants.MUEventNameKey] as! String?        
        cell.eventGroup?.text = event[Constants.MUEventGroupKey] as! String?
        cell.eventDateTime?.text = eventDateTime
        cell.eventRsvpNum?.text =   eventRsvpCount
        return cell
    }
    /***********************************************************************/
}
