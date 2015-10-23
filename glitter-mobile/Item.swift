import UIKit

struct Item {
    var text = ""
    var user = ""
    var glitter_count: Int?
    var id: Int?
    var created_at = NSDate()
    
    init(dictionary: NSDictionary) {
        text =  dictionary["text"] as! String
        user = dictionary["user"] as! String
        glitter_count = dictionary["glitter_count"] as? Int
        id = dictionary["id"] as? Int
        let stringDate = dictionary["created_at"] as! String
        created_at = timeDateFormat(stringDate)
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
