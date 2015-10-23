import UIKit

class ItemDetailViewController: UIViewController {
    var item: Item?
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let itemsString = "v1/items"
    let accessToken = Secret().value
    var session: NSURLSession!
    var glitterCount = 0
    
    @IBOutlet weak var glitterButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var glitterCountLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var bubbleView: UIView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        session = NSURLSession.sharedSession()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.bubblegumPinkColor()
        textField?.text = item!.text
        textField?.font?.fontWithSize(21.0)
        authorName?.text = "- \(item!.user)"
        authorName?.textColor = UIColor.magentaPinkColor()
        textField?.textColor = UIColor.flamingoPinkColor()
        glitterCountLabel?.textColor = UIColor.magentaPinkColor()
        glitterCountLabel?.text = "glitter: \(item!.glitter_count!)"
        bubbleView.layer.backgroundColor = UIColor.barelyPinkColor().CGColor
        bubbleView.layer.cornerRadius = 15
    }
    
    @IBAction func glitterItem() {
        let api_token: String = KeychainWrapper.stringForKey("api_token")!
        let user_id: String = KeychainWrapper.stringForKey("id")!
        let item_id = item!.id!
        let glitterString = "/\(item_id)/glitter"
        
        // Build the URL
        let urlString = baseURLSecureString + itemsString + glitterString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["id": item_id]
        }
        
        // Configure the request
        let request = NSMutableURLRequest(URL: url)
        do { let requestHTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 0)
            )
            
            request.HTTPMethod = "POST"
            request.HTTPBody = requestHTTPBody
            request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
            request.setValue(api_token, forHTTPHeaderField: "X-API-TOKEN")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Make the request
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                
                if let error = downloadError {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Glitter load error"
                    }
                } else {
                    // Parse the data
                    do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        // Use the data
                        if let success = parsedResult["success"] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.item?.glitter_count! += 1
                                self.glitterCountLabel?.text! = "glitter: \(self.item!.glitter_count!)"
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.debugTextLabel.text = "Glitter failed"
                            }
                        }
                    } catch {}
                }
            }
            // Start the request
            task.resume()
        } catch {}
    }
}
