import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var switchSignUpSignInButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    let baseURLSecureString = "http://glitter-app.herokuapp.com/v1"
    let authenticationValidationString = "/session"
    let signUpString = "/users"
    let accessToken = Secret().value
    var session: NSURLSession!
    let signUpTextLabel = "Sign up"
    let signInTextLabel = "Sign in"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = NSURLSession.sharedSession()

        // Do any additional setup after loading the view, typically from a nib.
        self.emailTextField.delegate = self;
        emailTextField.becomeFirstResponder()
        usernameTextField.hidden = true
        continueButton.layer.cornerRadius = 10;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Actions
    
    @IBAction func didPressLogin(sender: AnyObject) {
        if emailTextField.text!.isEmpty {
            debugTextLabel.text = "Email Empty"
        } else if passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Password Empty"
        } else if !isValidEmail(emailTextField.text!) {
            debugTextLabel.text = "Not a valid email address"
        } else if isSigningUp() {
            if usernameTextField.text!.isEmpty {
                debugTextLabel.text = "Username empty"
            } else if usernameTextField.text!.characters.count >= 15 {
                debugTextLabel.text = "Username must be less than 15 characters"
            } else {
                self.authenticate(signUpString, params: ["user": ["username": usernameTextField!.text!, "email": emailTextField!.text!, "password": passwordTextField!.text!]])
            }
        } else {
            self.authenticate(authenticationValidationString, params: ["session": ["email": emailTextField!.text!, "password": passwordTextField!.text!]])
        }
    }
    
    private func isSigningUp() -> Bool {
        return continueButton.titleLabel!.text == signUpTextLabel
    }
    
    @IBAction func didPressSwitchSignUpSignIn(sender: AnyObject) {
        if isSigningUp() {
            continueButton.setTitle(signInTextLabel, forState: UIControlState.Normal)
            switchSignUpSignInButton.setTitle(signUpTextLabel, forState: UIControlState.Normal)
            usernameTextField.hidden = true
        } else {
            continueButton.setTitle(signUpTextLabel, forState: UIControlState.Normal)
            switchSignUpSignInButton.setTitle(signInTextLabel, forState: UIControlState.Normal)
            usernameTextField.hidden = false
        }
    }
    
    func authenticate(requestString: String, params: [String : AnyObject]) {
        // Build the URL
        let urlString = baseURLSecureString + requestString
        let url = NSURL(string: urlString)!
        var params: [String: AnyObject] {
            return params
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
                            if let username = current_user["username"] {
                                self.defaults.setObject(username!, forKey: "username")
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
            self.dismissViewControllerAnimated(false, completion: nil)
            let viewController = self.storyboard?.instantiateInitialViewController()
            self.presentViewController(viewController!, animated: true, completion: nil)
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
        else if emailTextField.isFirstResponder() {
            emailTextField.resignFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
