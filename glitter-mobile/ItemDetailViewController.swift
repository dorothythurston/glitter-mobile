import UIKit

class ItemDetailViewController: UIViewController {
    var item: Item?
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let itemsString = "v1/items"
    let accessToken = Secret().value
    var session: NSURLSession!
    
    @IBOutlet weak var glitterButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var glitterCountLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        session = NSURLSession.sharedSession()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.greyPurpleColor()
        textField?.text = item!.text
        textField?.font?.fontWithSize(21.0)
        authorName?.text = "\(item!.user)"
        authorName?.textColor = UIColor.brightPurpleColor()
        textField?.textColor = UIColor.princessPurpleColor()
        glitterCountLabel?.textColor = UIColor.brightPurpleColor()
        glitterCountLabel?.text = "glitter: \(item!.glitter_count!)"
        createdAt?.text = formatDate(item!.created_at)
        createdAt?.textColor = UIColor.brightPurpleColor()
        bubbleView.layer.backgroundColor = UIColor.barelyPurpleColor().CGColor
        bubbleView.layer.cornerRadius = 15
        
        if item?.user == KeychainWrapper.stringForKey("email") {
            deleteButton.hidden = false
            glitterButton.hidden = true
        }
    }
    
    private func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        let stringValue = formatter.stringFromDate(date)
        return stringValue
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
                
                if let _ = downloadError {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Glitter load error"
                    }
                } else {
                    // Parse the data
                    do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        // Use the data
                        if let _ = parsedResult["success"] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.item?.glitter_count! += 1
                                self.glitterCountLabel?.text! = "glitter: \(self.item!.glitter_count!)"
                                self.shakeAnimation(self.glitterCountLabel)
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
    
    @IBAction func deleteItem() {
        let api_token: String = KeychainWrapper.stringForKey("api_token")!
        let user_id: String = KeychainWrapper.stringForKey("id")!
        let item_id = item!.id!
        let itemIDString = "/\(item_id)"
        
        // Build the URL
        let urlString = baseURLSecureString + itemsString + itemIDString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["id": item_id]
        }
        
        // Configure the request
        let request = NSMutableURLRequest(URL: url)
        do { let requestHTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 0)
            )
            
            request.HTTPMethod = "DELETE"
            request.HTTPBody = requestHTTPBody
            request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
            request.setValue(api_token, forHTTPHeaderField: "X-API-TOKEN")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Make the request
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                
                if let _ = downloadError {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Request error"
                    }
                } else {
                    // Parse the data
                    do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        // Use the data
                        if let _ = parsedResult["success"] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.navigationController!.popViewControllerAnimated(true)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.debugTextLabel.text = "Request failed"
                            }
                        }
                    } catch {}
                }
            }
            // Start the request
            task.resume()
        } catch {}
    }
    
    private func shakeAnimation(target: AnyObject) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        var upRect: NSValue {
            return NSValue(CGPoint: CGPointMake(target.center.x - 10, target.center.y))
        }
        
        var downRect: NSValue {
            return NSValue(CGPoint: CGPointMake(target.center.x + 10, target.center.y))
        }
        animation.fromValue = upRect
        animation.toValue = downRect
        target.layer.addAnimation(animation, forKey: "position")
    }
}
