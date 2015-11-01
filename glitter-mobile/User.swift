import UIKit

struct User {
    var email = ""
    var followers: Int?
    
    init(dictionary: NSDictionary) {
        email =  dictionary["email"] as! String
        followers = dictionary["followers"] as? Int
    }
}