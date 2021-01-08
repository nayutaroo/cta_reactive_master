import Foundation

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)
    }

    class func stringFromDate(date: Date, format: String) -> String? {
        let formatter: DateFormatter = DateFormatter()
        guard let modifiedDate = Calendar.current.date(byAdding: .hour, value:9, to: date)
        else {return nil}
        
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        
        return formatter.string(from: modifiedDate)
    }
}


