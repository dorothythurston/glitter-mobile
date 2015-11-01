import UIKit

struct Activity {
    var actor_email = ""
    var user_id: Int?
    var type = ""
    var subject_id: Int?
    var subject_type = ""
    var actor_id: Int?
    var target_id: Int?
    var target_type = ""
    var created_at = NSDate()
    
    init(dictionary: NSDictionary) {
        actor_email =  dictionary["actor_email"] as! String
        user_id = dictionary["user_id"] as? Int
        type =  dictionary["type"] as! String
        subject_id = dictionary["subject_id"] as? Int
        subject_type = dictionary["subject_type"] as! String
        actor_id = dictionary["actor_id"] as? Int
        target_id = dictionary["target_id"] as? Int
        target_type = dictionary["target_type"] as! String
        let stringDate = dictionary["created_at"] as! String
        created_at = timeDateFormat(stringDate)
    }
    
    static func activitiesFromResults(json: [NSDictionary]) -> [Activity] {
        var activities: [Activity] = []
        
        for object in json {
            activities.append(Activity(dictionary: object))
        }
        
        return activities
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
