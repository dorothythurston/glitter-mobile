import UIKit

class NewItemViewController: UIViewController {
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!

    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let itemsString = "v1/items"
    let accessToken = Secret().value
    var session: NSURLSession!
    let placeHolderColor = UIColor.lightGrayColor()
    let typingColor = UIColor.brightPurpleColor()
    let placeHolderText = "What's happening?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.greyPurpleColor()
        
        session = NSURLSession.sharedSession()
        textField.delegate = self
        textField.text = placeHolderText
        textField.textColor = placeHolderColor
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = UIColor.barelyPurpleColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressSubmit() {
        if textField.text!.isEmpty || textField.text! == placeHolderText {
            debugTextLabel.text = "Scribe something :)"
        } else {
            self.createItem(textField!.text!)
        }
    }
    
    func createItem(text: String) {
        let api_token: String = KeychainWrapper.stringForKey("api_token")!
        let user_id: String = KeychainWrapper.stringForKey("id")!
        // Build the URL
        let urlString = baseURLSecureString + itemsString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["item": ["text": text, "user_id": user_id]]
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
                        self.debugTextLabel.text = "Item failed to be created for some reason"
                        //TODO: Fix error caused by App Transport Security
                    }
                    print("Could not complete the request \(error)")
                } else {
                    // Parse the data
                    do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        // Use the data
                        if let _ = parsedResult["success"] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.debugTextLabel.text = "Item failed to be created"
                            }
                        }
                    } catch {}
                }
            }
            // Start the request
            task.resume()
        } catch {}
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NewItemViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == placeHolderColor {
            textView.text = nil
            textView.textColor = typingColor
            textView.sizeToFit()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = placeHolderColor
        }
    }
    
}
