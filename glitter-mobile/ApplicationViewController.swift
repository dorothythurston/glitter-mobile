import UIKit

class ApplicationViewController: UIViewController {
    var activeViewController: UIViewController?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showViewController(initialViewController)
    }
    
    private var initialViewController: UIViewController {
        if let _ = defaults.stringForKey("username") {
            return mainViewController
        } else {
            return authenticationViewController
        }
    }
    
    private var authenticationViewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .None)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        return viewController
    }
    
    private var mainViewController: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .None)
        let viewController = storyboard.instantiateInitialViewController()
        return viewController!
    }
    
    private func showViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        
        activeViewController = viewController
    }
}