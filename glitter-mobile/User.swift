import UIKit

struct User {
    var email = ""
    var id: Int?
    var followers: Int?
    
    init(dictionary: NSDictionary) {
        email =  dictionary["email"] as! String
        followers = dictionary["followers"] as? Int
        id = dictionary["id"] as? Int
    }
    
    static func usersFromResults(json: [NSDictionary]) -> [User] {
        var users: [User] = []
        
        for object in json {
            users.append(User(dictionary: object))
        }
        
        return users
    }
}