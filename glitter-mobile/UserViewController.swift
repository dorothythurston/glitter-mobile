import UIKit

class UserViewController: UIViewController {
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let usersString = "v1/users"
    let accessToken = Secret().value
    let api_token = KeychainWrapper.stringForKey("api_token")
    var session: NSURLSession!
    var user_id: Int?
    var user: User?
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userFollowerCount: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
                            self.username.text = self.user!.email
                            self.userFollowerCount.text = "followers: \(self.user!.followers!)"
                            self.activityIndicator.stopAnimating()
                        }
                    } 
                } catch {
                }
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
}
