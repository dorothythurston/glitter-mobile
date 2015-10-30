import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var switchSignUpSignInButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    let baseURLSecureString = "http://glitter-app.herokuapp.com/v1"
    let authenticationValidationString = "/session"
    let signUpString = "/users"
    let accessToken = Secret().value
    var userParam =  "user"
    var sessionParam = "session"
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: write a better way of checking for current user
        if let _ = KeychainWrapper.stringForKey("api_token") {
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
            debugTextLabel.text = "Email Empty"
        } else if passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Password Empty"
        } else {
            if isValidEmail(usernameTextField.text!) {
                if continueButton.titleLabel!.text == "Sign in" {
                    self.authenticate(authenticationValidationString, param: sessionParam)
                } else {
                    self.authenticate(signUpString, param: userParam)
                }
            } else {
                debugTextLabel.text = "Not a valid email address"
            }
        }
    }
    
    @IBAction func didPressSwitchSignUpSignIn(sender: AnyObject) {
        if continueButton.titleLabel!.text == "Sign in" {
            continueButton.setTitle("Sign up", forState: UIControlState.Normal)
            switchSignUpSignInButton.setTitle("Sign in", forState: UIControlState.Normal)
        } else {
            continueButton.setTitle("Sign in", forState: UIControlState.Normal)
            switchSignUpSignInButton.setTitle("Sign up", forState: UIControlState.Normal)
        }
    }
    
    func authenticate(requestString: String, param: String ) {
        // Build the URL
        let urlString = baseURLSecureString + requestString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return [param: ["email": usernameTextField!.text!, "password": passwordTextField!.text!]]
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
                                self.debugTextLabel.text = "Incorrect information given"
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
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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
