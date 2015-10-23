import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    let baseURLSecureString = "http://glitter-app.herokuapp.com/"
    let authenticationValidationString = "v1/session"
    let accessToken = Secret().value
    var username = String?()
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: write a better way of checking for current user
        if let api_token = KeychainWrapper.stringForKey("api_token") {
            completeLogin()
        }
        session = NSURLSession.sharedSession()

        // Do any additional setup after loading the view, typically from a nib.
        self.usernameTextField.delegate = self;
        usernameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Actions
    
    @IBAction func didPressLogin(sender: AnyObject) {
        if usernameTextField.text!.isEmpty {
            debugTextLabel.text = "Username Empty"
        } else if passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Password Empty"
        } else {
            self.login(usernameTextField.text!, password: passwordTextField.text!)
        }
    }
    
    func login(username: String, password: String) {
        // Build the URL
        let urlString = baseURLSecureString + authenticationValidationString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return ["session": ["email": username, "password": password]]
        }

        // Configure the request
        let request = NSMutableURLRequest(URL: url)
        do { let requestHTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 0)
            )
            
            request.HTTPMethod = "POST"
            request.HTTPBody = requestHTTPBody
            request.setValue(accessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            // Make the request
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                
                if let error = downloadError {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugTextLabel.text = "Login failed."
                        //TODO: Fix error caused by App Transport Security
                    }
                    print("Could not complete the request \(error)")
                } else {
                    // Parse the data
                    do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        // Use the data
                        if let current_user = parsedResult["current_user"] {
                            if let id = current_user["id"] {
                                self.setKeychainValue(id!, keyName: "id")
                            }
                            if let email = current_user["email"] {
                                self.setKeychainValue(email!, keyName: "email")
                            }
                            if let api_token = current_user["api_token"] {
                                self.setKeychainValue(api_token!, keyName: "api_token")
                            }
                            self.completeLogin()
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.debugTextLabel.text = "Incorrect login information"
                            }
                        }
                    } catch {}
                }
            }
            // Start the request
            task.resume()
        } catch {}
    }

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func setKeychainValue(value: AnyObject, keyName: String) {
        let escapedValue = "\(value)"
        KeychainWrapper.setString(escapedValue, forKey: keyName)
    }
}

extension LoginViewController {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        }
        else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
