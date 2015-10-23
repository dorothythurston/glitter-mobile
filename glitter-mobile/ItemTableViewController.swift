import UIKit

class ItemTableViewController: UITableViewController {
    var session: NSURLSession!
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let accessToken = Secret().value
    let itemsString = "v1/items"
    
    var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            getItems()
        } else {
            navigateToLogin()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "ItemTableViewCell"
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! ItemTableViewCell!
        
        // Set cell defaults
        cell.textField!.text = item.text
        cell.authorName.text = item.user
        cell.glitterCount.text = "glitter: \(item.glitter_count!)"
        
        
        return cell
    }
    
    func getItems() {
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            // Build the URL
            let urlString = baseURLSecureString + itemsString
            let url = NSURL(string: urlString)!
            var params: [String: AnyObject] {
                return ["api_token": "\(api_token)"]
            }
            
            print(api_token)
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
                        print(self.items)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                    } catch {}
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Navigation
    
    func navigateToLogin() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! UITableViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

