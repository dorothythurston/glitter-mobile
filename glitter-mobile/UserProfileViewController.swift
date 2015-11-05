import UIKit


class UserProfileViewController: UIViewController {
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let usersString = "v1/users"
    let followString = "/follow"
    let unfollowString = "/unfollow"
    let accessToken = Secret().value
    let api_token = KeychainWrapper.stringForKey("api_token")
    var session: NSURLSession!
    var user_id: Int?
    var user: User?
    var items: [Item] = []
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userFollowerCount: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        user_id =  Int(KeychainWrapper.stringForKey("id")!)
        
        itemsTableView.emptyDataSetSource = self;
        itemsTableView.emptyDataSetDelegate = self;
        itemsTableView.estimatedRowHeight = 70.0
        itemsTableView.rowHeight = UITableViewAutomaticDimension
        username.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        session = NSURLSession.sharedSession()
        getUserInfo(user_id!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserInfo(user_id: Int) {
        // Build the URL
        let urlString = baseURLSecureString + usersString + "/\(user_id)"
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["user":["id": user_id]]
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
                do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    // Use the data
                    if let got_user = parsedResult["user"] as? NSDictionary {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.user = User(dictionary: got_user)
                            self.items = self.user!.items!
                            self.itemsTableView.reloadData()
                            self.username.text = self.user!.username
                            self.userFollowerCount.text = "\(self.user!.followers!.count)"
                            
                            self.activityIndicator.stopAnimating()
                        }
                    }
                } catch {
                }
            }
        }
        task.resume()
    }
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "itemCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UserItemTableViewCell!
        let item = items[indexPath.row]
        
        cell.textField?.text = item.text
        cell.createdAt?.text = formatDate(item.created_at)
        cell.textField?.font?.fontWithSize(19.0)
        cell.authorName?.text = "\(self.user!.username)"
        cell.bubbleView.layer.backgroundColor = UIColor.barelyPurpleColor().CGColor
        cell.bubbleView.layer.cornerRadius = 15
        return cell
    }
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        let stringValue = formatter.stringFromDate(date)
        return stringValue
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ItemViewController") as! ItemViewController
        controller.item_id = items[indexPath.row].id
        self.navigationController!.pushViewController(controller, animated: true)
    }
}

extension UserProfileViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "This is your profile"
        
        let attributedText = NSAttributedString(string: text, attributes:[NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0),
            NSForegroundColorAttributeName: UIColor.barelyPurpleColor()
            ])
        return attributedText
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "When you post a new item it will show up here"
        
        let attributedText = NSAttributedString(string: text, attributes:[NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.barelyPurpleColor()
            ])
        return attributedText
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let imageName = "empty_items"
        return UIImage(named: imageName)
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        return items.isEmpty
    }
}

