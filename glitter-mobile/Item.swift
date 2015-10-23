import UIKit

struct Item {
    var text = ""
    var user = ""
    var glitter_count: Int?
    
    init(dictionary: NSDictionary) {
        text =  dictionary["text"] as! String
        user = dictionary["user"] as! String
        glitter_count = dictionary["glitter_count"] as? Int
    }
    
    static func itemsFromResults(json: [NSDictionary]) -> [Item] {
        var items: [Item] = []
        
        for object in json {
            items.append(Item(dictionary: object))
        }
        
        return items
    }
    
}
