import UIKit

struct Item {
    var text = ""
    var user = ""
    var glitter_count: Int?
    var id: Int?
    var created_at = ""
    
    init(dictionary: NSDictionary) {
        text =  dictionary["text"] as! String
        user = dictionary["user"] as! String
        glitter_count = dictionary["glitter_count"] as? Int
        id = dictionary["id"] as? Int
        created_at = dictionary["created_at"] as! String
    }
    
    static func itemsFromResults(json: [NSDictionary]) -> [Item] {
        var items: [Item] = []
        
        for object in json {
            items.append(Item(dictionary: object))
        }
        
        return items
    }
    
}

