import UIKit

class UsersTableViewController: UITableViewController {
    var session: NSURLSession!
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
       let usersString = "v1/users"
    let api_token = KeychainWrapper.stringForKey("api_token")
    let accessToken = Secret().value
    var users: [User] = []
    
    @IBOutlet weak var activitiesTableView: UITableView!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.greyPurpleColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        session = NSURLSession.sharedSession()
        
        setActivityIndicator()
        
        getUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setActivityIndicator() {
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        activityIndicator.center = CGPoint(x:self.view.bounds.size.width / 2, y:self.view.bounds.size.height / 2)
        activityIndicator.backgroundColor = UIColor.greyPurpleColor()
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func getUsers() {
        // Build the URL
        let urlString = baseURLSecureString + usersString
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
                    self.users = User.getOtherUsersFromResults(parsedResult)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.removeFromSuperview()
                    }
                } catch {
                }
            }
        }
        task.resume()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userInfoCell", forIndexPath: indexPath) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.username.text = user.username
        cell.username.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserViewController") as! UserViewController
        controller.user_id = user.id
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
