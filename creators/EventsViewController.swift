//
//  EventsViewController.swift
//  creators
//
//  Created by Natasja Nielsen on 7/23/14.
//  Copyright (c) 2014 Creators Co-op. All rights reserved.
//

import Foundation

class EventsTableViewCell: SWTableViewCell {
    @IBOutlet var title: UILabel?
    @IBOutlet var details: UILabel?
    @IBOutlet var day: UILabel?
    @IBOutlet var date: UILabel?
    @IBOutlet var month: UILabel?



    override  init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
    }

   required init(coder aDecoder: NSCoder) {
       //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
   }
}

class EventsViewController: UITableViewController, UITableViewDelegate, SWTableViewCellDelegate, UITableViewDataSource {
    // define the class
    var eventsData: NSArray = []
    var eventsPhotos = Dictionary<String, PFImageView>()
    var eventsRsvps = Dictionary<String, PFObject>()
/*
    func leftButtons() -> NSArray {
        var leftUtilityButtons: NSMutableArray = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 1.0), title: "Going")
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.203, green: 0.667, blue: 0.863, alpha: 1.0), title: "Maybe")
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), title: "Not")
        
        return leftUtilityButtons
    }

    
    func rightButtons() -> NSArray {
        var rightUtilityButtons: NSMutableArray = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0), title: "R_One")
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.07, green: 0.75, blue: 0.16, alpha: 1.0), title: "R_Two")
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), title: "R_Three")
        
        return rightUtilityButtons
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex withIndex: NSInteger) {
        let indexPath = self.tableView.indexPathForCell(cell)
        let rsvpEvent = self.eventsData.objectAtIndex(indexPath!.row) as PFObject
        let rsvpMember = PFUser.currentUser()
        var rsvpStatus = ""

        switch withIndex {
            case 0:
                println("Left One")
                rsvpStatus = "GOING"
            case 1:
                println("Left Two ")
                rsvpStatus = "MAYBE_GOING"
            case 2:
                println("Left Three ")
                rsvpStatus = "NOT_GOING"
            default:
                println("Wut.")
        }
        
        var eventRsvp = self.eventsRsvps[rsvpEvent.objectId]!
        eventRsvp["status"] = rsvpStatus
        eventRsvp.saveEventually()
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex withIndex: NSInteger) {
        switch withIndex {
            case 0:
                println("Right One")
            case 1:
                println("Right Two ")
            case 2:
                println("Right Three ")
            default:
                println("Right Wut.")
        }
    }
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = ShiftColor.Blue.color()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EventsCell")
        
        var query = PFQuery(className: "Event")
        query.findObjectsInBackgroundWithBlock({(NSMutableArray objects, NSError error) in
            if (error != nil) {
                NSLog("error " + error.localizedDescription)
            }
            else {
                self.eventsData = objects

                for element : AnyObject in self.eventsData {
                    if let event = element as? PFObject  {
                        // load photo to eventsPhotos
                        var photo: PFImageView = PFImageView()
                        photo.image = UIImage(named: "square")
                        photo.file = event["photo"] as? PFFile
                        photo.loadInBackground({(UIImage image, NSError error) in
                            if (error != nil) {
                                NSLog("error " + error.localizedDescription)
                            } else {
                                self.tableView.reloadData()
                            }
                        })
                        self.eventsPhotos.updateValue(photo, forKey: event.objectId)
    
                        // load event to eventsRsvps
                        let rsvpEvent = event
                        let rsvpMember = PFUser.currentUser()
                        var query = PFQuery(className: "EventRsvp")
                        query.whereKey("event", equalTo: rsvpEvent)
                        query.whereKey("member", equalTo: rsvpMember)
                        query.getFirstObjectInBackgroundWithBlock({(PFObject eventRsvp, NSError error) in
                            if (error != nil) {
                                NSLog("RSVP - Could not retrieve EventRsvp. " + error.localizedDescription)
                                // if the user has not rsvp'd for this event, set empty object
                                var eventRsvp = PFObject(className: "EventRsvp")
                                eventRsvp["event"] = rsvpEvent
                                eventRsvp["member"] = rsvpMember
                                eventRsvp["status"] = ""
                                self.eventsRsvps.updateValue(eventRsvp, forKey: event.objectId)
                            } else {
                                self.eventsRsvps.updateValue(eventRsvp, forKey: event.objectId)
                            }
                        })
                        //println(element)

                    }
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view data source
    
    /*override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
    }*/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as EventsTableViewCell
        
        if self.eventsData.count > 0 {
            let event = self.eventsData.objectAtIndex(indexPath.row) as PFObject
            let title = String(event["title"] as NSString)
            let details = String(event["details"] as NSString)
            
            var df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd-EEEE"
            var dateString: NSString = df.stringFromDate(event["startDate"] as NSDate)
            
            var month = dateString.substringWithRange(NSRange(location: 5, length: 2))
            var date = dateString.substringWithRange(NSRange(location: 8, length: 2))
            var day = dateString.substringWithRange(NSRange(location: 11, length: 3))
            
            var monthVal = month.toInt()
            month = Months.fromRaw(monthVal!)!.month()

            //cell.leftUtilityButtons = self.leftButtons()
            //cell.rightUtilityButtons = self.rightButtons()
            cell.delegate = self
            
            cell.title!.text = title
            cell.details!.numberOfLines = 3
            cell.details!.text = details
            cell.day!.text = day
            cell.date!.text = date
            cell.month!.text = month
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var eventViewController: EventViewController = segue.destinationViewController as EventViewController
        var eventIndex = tableView.indexPathForSelectedRow()!.row
        var selectedEvent = self.eventsData.objectAtIndex(eventIndex) as PFObject
        eventViewController.event = selectedEvent
        eventViewController.image = self.eventsPhotos[selectedEvent.objectId]!.image!
        eventViewController.rsvp = self.eventsRsvps[selectedEvent.objectId]!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("eventSegue", sender: self)
    }
    
}
