import UIKit

struct Item {
    var text = ""
    var user_id: Int?
    var user_username = ""
    var glitter_count: Int?
    var id: Int?
    var created_at = NSDate()
    var current_user_glittered: Bool?
    
    init(dictionary: NSDictionary) {
        text =  dictionary["text"] as! String
        user_id = dictionary["user_id"] as? Int
        glitter_count = dictionary["glitter_count"] as? Int
        id = dictionary["id"] as? Int
        let stringDate = dictionary["created_at"] as! String
        created_at = timeDateFormat(stringDate)
        if let username = dictionary["user_username"] as? String {
            user_username =  username
        }
        if let glittered = dictionary["current_user_glittered"] as? Bool {
            current_user_glittered = glittered
        }
    }
    
    static func itemsFromResults(json: [NSDictionary]) -> [Item] {
        var items: [Item] = []
        
        for object in json {
            items.append(Item(dictionary: object))
        }
        
        return items
    }
    
    func timeDateFormat(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let availabletoDateTime = dateFormatter.dateFromString(string)
        return availabletoDateTime!
    }
}
