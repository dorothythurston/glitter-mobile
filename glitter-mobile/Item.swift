import UIKit

struct Item {
    var text = ""
    var user_id: Int?
    var user_email = ""
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
        user_email =  dictionary["user_email"] as! String
        current_user_glittered = dictionary["current_user_glittered"] as? Bool
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
