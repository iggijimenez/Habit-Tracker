//
//  HabitItem+CoreDataProperties.swift
//  Habit Tracker
//
//  Created by jimenez on 12/13/21.
//
//

import Foundation
import CoreData


extension HabitItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?

}

extension HabitItem : Identifiable {

}
