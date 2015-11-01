import UIKit

class ItemActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var actorName: UIButton!
    @IBOutlet weak var activityText: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    @IBAction func didPressActorEmail() {
        print("pressed actor email")
    }
}
