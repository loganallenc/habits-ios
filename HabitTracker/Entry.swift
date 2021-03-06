//
//  Entry.swift
//  Tailor
//
//  Created by Logan Allen on 1/29/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//

import Foundation
import CoreData


class Entry: NSManagedObject {
    
    @NSManaged var note: String?
    @NSManaged var habit: Habit

    @NSManaged var date: NSDate
    @NSManaged var year: NSNumber
    @NSManaged var month: NSNumber
    @NSManaged var day: NSNumber
    @NSManaged var timezone: NSNumber

    override func awakeFromInsert() {
        super.awakeFromInsert()
        let nowDate = NSDate()
        self.date = nowDate
        let formatter = NSDateFormatter()

        formatter.dateFormat = "yyyy"
        self.year = Int(formatter.stringFromDate(nowDate))!

        formatter.dateFormat = "MM"
        self.month = Int(formatter.stringFromDate(nowDate))!

        formatter.dateFormat = "dd"
        self.day = Int(formatter.stringFromDate(nowDate))!

        formatter.dateFormat = "Z"
        self.timezone = Int(formatter.stringFromDate(nowDate))!
    }

    func sameDay(date: NSDate) -> Bool {
        let formatter = NSDateFormatter()

        formatter.dateFormat = "yyyy"
        let year = Int(formatter.stringFromDate(date))!

        formatter.dateFormat = "MM"
        let month = Int(formatter.stringFromDate(date))!

        formatter.dateFormat = "dd"
        let day = Int(formatter.stringFromDate(date))!

        formatter.dateFormat = "Z"
        let timezone = Int(formatter.stringFromDate(date))!

        if (year == self.year && month == self.month && day == self.day && timezone == self.timezone) {
            return true
        }
        return NSDate.sameDay(self.date, otherDate: date)
    }
}
