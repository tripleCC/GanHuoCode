//
//  NSDate+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/11/19.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

let oneDay: NSTimeInterval = 60 * 60 * 24
extension NSDate {
    var isWeekend: Bool {
        let weekday = (NSCalendar.currentCalendar().weekdayWithDate(self) + 7) % 8
        debugPrint(weekday)
        return weekday == 0 || weekday == 1
    }
    
    public class func currentTime() -> (Int, Int, Int) {
        return NSDate.timeSinceNowByDayInterval(0)
    }
    
    public class func timeSinceNowByDayInterval(dayInterval: NSTimeInterval) -> (Int, Int, Int) {
        let calender = NSCalendar.currentCalendar()
        let day = calender.component(NSCalendarUnit.Day, fromDate: NSDate(timeIntervalSinceNow: oneDay * dayInterval))
        let month = calender.component(NSCalendarUnit.Month, fromDate: NSDate(timeIntervalSinceNow: oneDay * dayInterval))
        let year = calender.component(NSCalendarUnit.Year, fromDate: NSDate(timeIntervalSinceNow: oneDay * dayInterval))
        return (year, month, day)
    }
    
    public class func dayIntervalFromYear(year: Int, month: Int, day: Int) -> NSTimeInterval {
        let (yearC, monthC, dayC) = timeSinceNowByDayInterval(0)
        let start = String(format: "%04d-%02d-%02d", arguments: [yearC, monthC, dayC])
        let end = String(format: "%04d-%02d-%02d", arguments: [year, month, day])
        let dateFormtter = NSDateFormatter()
        dateFormtter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormtter.dateFromString(start)
        let endDate = dateFormtter.dateFromString(end)
        
        let cal = NSCalendar.currentCalendar()
        let components = cal.components(.Day, fromDate: endDate!, toDate: startDate!, options: NSCalendarOptions.WrapComponents)

        return NSTimeInterval(components.day)
    }
}