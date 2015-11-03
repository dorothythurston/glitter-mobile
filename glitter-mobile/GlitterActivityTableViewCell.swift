import UIKit

class GlitterActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var actorName: UIButton!
    @IBOutlet weak var activityText: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    @IBAction func didPressActorUsername() {
        print("pressed actor username")
    }
}
