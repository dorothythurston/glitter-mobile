import UIKit

class ActivitiesViewController: UIViewController {
    var session: NSURLSession!
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let accessToken = Secret().value
    let activitiesString = "v1/activities"
    var activities: [Activity] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    @IBOutlet weak var activitiesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activitiesTableView.estimatedRowHeight = 70.0
        activitiesTableView.rowHeight = UITableViewAutomaticDimension
        activitiesTableView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        session = NSURLSession.sharedSession()
        
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            getActivities(api_token)
        } else {
            navigateToLogin()
        }
        
        activityIndicator.backgroundColor = UIColor.greyPurpleColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getActivities(api_token: String) {
        // Build the URL
        let urlString = baseURLSecureString + activitiesString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["api_token": "\(api_token)"]
        }
        
        // Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
        request.setValue(api_token, forHTTPHeaderField: "X-API-TOKEN")
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                // Parse the data
                do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
                    // Use the data
                    self.activities = Activity.activitiesFromResults(parsedResult)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activitiesTableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                } catch {}
            }
        }
        task.resume()
    }
    
    //MARK: - Navigation
    
    func navigateToLogin() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func logOut() {
        KeychainWrapper.removeObjectForKey("id")
        KeychainWrapper.removeObjectForKey("email")
        KeychainWrapper.removeObjectForKey("api_token")
        let controller = 
        self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
}

extension ActivitiesViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if activities[indexPath.row].type == "FollowingRelationshipActivity" {
            let cell = tableView.dequeueReusableCellWithIdentifier("followingRelationshipActivityCell", forIndexPath: indexPath) as! FollowingRelationshipActivityTableViewCell
            let activity = activities[indexPath.row]
            
            cell.actorName.setTitle(activity.actor_email, forState: UIControlState.Normal)
            cell.activityText.text = "followed \(activity.target_id)"
            cell.createdAt.text = formatDate(activity.created_at)
            cell.bubbleView.layer.cornerRadius = 15
            
            return cell
        } else if activities[indexPath.row].type == "ItemActivity" {
            let cell = tableView.dequeueReusableCellWithIdentifier("itemActivityCell", forIndexPath: indexPath) as! ItemActivityTableViewCell
            let activity = activities[indexPath.row]
            
            cell.actorName.setTitle(activity.actor_email, forState: UIControlState.Normal)
            cell.bubbleView.layer.cornerRadius = 15
            cell.createdAt.text = formatDate(activity.created_at)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("glitterActivityCell", forIndexPath: indexPath) as! GlitterActivityTableViewCell
            let activity = activities[indexPath.row]
            
            cell.actorName.setTitle(activity.actor_email, forState: UIControlState.Normal)
            cell.bubbleView.layer.cornerRadius = 15
            cell.createdAt.text = formatDate(activity.created_at)
            return cell
        }
    }
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        let stringValue = formatter.stringFromDate(date)
        return stringValue
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if activities[indexPath.row].type == "FollowingRelationshipActivity" {
            let activity = activities[indexPath.row]
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserViewController") as! UserViewController
            controller.user_id = activity.actor_id
            self.navigationController!.pushViewController(controller, animated: true)
        } else if activities[indexPath.row].type == "GlitterActivity" {
            let activity = activities[indexPath.row]
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ItemViewController") as! ItemViewController
            controller.item_id = activity.subject_id
         
            self.navigationController!.pushViewController(controller, animated: true)
        } else  {
            let activity = activities[indexPath.row]
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ItemViewController") as! ItemViewController
            controller.item_id = activity.target_id
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            getActivities(api_token)
        } else {
            navigateToLogin()
        }
    }
}