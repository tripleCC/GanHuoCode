//
//  NSCalender+Extension.swift
//  GanHuo
//
//  Created by tripleCC on 16/1/24.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import Foundation

extension NSCalendar {
    func dateWithTime(time: (year: Int, month: Int, day: Int)) -> NSDate? {
        let calender = NSCalendar.currentCalendar()
        // Why time.day should add 1 ?
        return calender.dateWithEra(calender.component(.Era, fromDate: NSDate()), year: time.year, month: time.month, day: time.day + 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
    }
    
}