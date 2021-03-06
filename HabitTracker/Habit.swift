//
//  Habit.swift
//  Tailor
//
//  Created by Logan Allen on 1/29/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//

import Foundation
import CoreData


class Habit: NSManagedObject {

    @NSManaged var name: String

    @NSManaged var monday: NSNumber?
    @NSManaged var tuesday: NSNumber?
    @NSManaged var wednesday: NSNumber?
    @NSManaged var thursday: NSNumber?
    @NSManaged var friday: NSNumber?
    @NSManaged var saturday: NSNumber?
    @NSManaged var sunday: NSNumber?

    @NSManaged var entries: Set<Entry>
    @NSManaged var triggers: Set<NSManagedObject>

    @NSManaged var needsAction: NSNumber

    // latest entry is first
    var orderedEntries: [Entry] {
        let ordered = self.entries.sort { $0.date.compare($1.date).rawValue > 0 }
        return ordered
    }

    var orderedTriggers: [NSManagedObject] {
        let ordered = self.triggers.sort { $0.hashValue > $1.hashValue }
        return ordered
    }

    lazy var isTodayComplete: Bool = {
        if let firstObject = self.orderedEntries.first {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let todayString = formatter.stringFromDate(NSDate())
            let mostRecentEntryString = formatter.stringFromDate(firstObject.date)
            return todayString == mostRecentEntryString
        }
        return false
    }()

}