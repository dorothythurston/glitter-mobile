import UIKit

class ItemsViewController: UIViewController {
    var session: NSURLSession!
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let accessToken = Secret().value
    let itemsString = "v1/items"
    var items: [Item] = []
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsTableView.estimatedRowHeight = 70.0
        itemsTableView.rowHeight = UITableViewAutomaticDimension
        displayTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        session = NSURLSession.sharedSession()
        
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            getItems(api_token)
        } else {
            navigateToLogin()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getItems(api_token: String) {
        // Build the URL
        let urlString = baseURLSecureString + itemsString
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
                    self.items = Item.itemsFromResults(parsedResult)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.itemsTableView.reloadData()
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
    
    func displayTableView() {
        activityIndicator.stopAnimating()
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

extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "ItemTableViewCell"
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! ItemTableViewCell!
        
        // Set cell defaults
        cell.contentView.backgroundColor = UIColor.bubblegumPinkColor()
        cell.textField?.text = item.text
        cell.textField?.font?.fontWithSize(21.0)
        cell.authorName?.text = "- \(item.user)"
        cell.authorName?.textColor = UIColor.magentaPinkColor()
        cell.textField?.textColor = UIColor.flamingoPinkColor()
        cell.glitterCount?.textColor = UIColor.magentaPinkColor()
        cell.glitterCount?.text = "glitter: \(item.glitter_count!)"
        cell.bubbleView.layer.backgroundColor = UIColor.barelyPinkColor().CGColor
        cell.bubbleView.layer.cornerRadius = 15
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ItemDetailViewController") as! ItemDetailViewController
        controller.item = items[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
