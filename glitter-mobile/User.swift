import UIKit

struct User {
    var username = ""
    var id: Int?
    var followers: [Int]?
    var items: [Item]?
    
    init(dictionary: NSDictionary) {
        username =  dictionary["username"] as! String
        followers = dictionary["followers"] as? [Int]
        id = dictionary["id"] as? Int
        if let results = (dictionary["items"] as? [NSDictionary]) {
            items = Item.itemsFromResults(results)
        }
    }
    
    static func usersFromResults(json: [NSDictionary]) -> [User] {
        var users: [User] = []
        
        for object in json {
            users.append(User(dictionary: object))
        }
        
        return users
    }
}