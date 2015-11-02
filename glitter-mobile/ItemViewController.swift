import UIKit

class ItemViewController: UIViewController {
    var item: Item?
    var item_id: Int?
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let itemsString = "v1/items"
    let accessToken = Secret().value
    let api_token = KeychainWrapper.stringForKey("api_token")
    var session: NSURLSession!
    
    @IBOutlet weak var glitterButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var glitterCountLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        session = NSURLSession.sharedSession()
        getItemInfo(item_id!)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.greyPurpleColor()
        bubbleView.layer.backgroundColor = UIColor.barelyPurpleColor().CGColor
        bubbleView.layer.cornerRadius = 15
        
        if item?.user_email == KeychainWrapper.stringForKey("email") {
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
    
    func getItemInfo(item_id: Int) {
        // Build the URL
        let urlString = baseURLSecureString + itemsString + "/\(item_id)"
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["item":["id": item_id]]
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
                    if let got_item = parsedResult["item"] as? NSDictionary {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.item = Item(dictionary: got_item)
                            self.authorName.text = self.item!.user_email
                            self.glitterCountLabel.text = "glitter: \(self.item!.glitter_count!)"
                            self.createdAt.text = self.formatDate((self.item?.created_at)!)
                            self.textField.text = self.item!.text
                            if self.item?.current_user_glittered == true {
                                self.glitterButton.hidden = true
                                
                            }
                            self.activityIndicator.stopAnimating()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.debugTextLabel.text = "404 Not found"
                            self.bubbleView.hidden = true
                            self.glitterButton.hidden = true
                            self.textField.hidden = true
                            self.createdAt.hidden = true
                            self.authorName.hidden = true
                            self.deleteButton.hidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                } catch {
                }
            }
        }
        task.resume()
    }
    
    func timeDateFormat(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let availabletoDateTime = dateFormatter.dateFromString(string)
        return availabletoDateTime!
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
                                self.glitterButton.hidden = true
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
