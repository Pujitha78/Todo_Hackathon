//
//  TaskEntity+CoreDataProperties.swift
//  Todo_hackathon
//
//  Created by Pujitha Kadiyala on 3/8/26.
//
//

import Foundation
import CoreData

extension TaskEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
    
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var taskDescription: String?
    @NSManaged var isCompleted: Bool
    @NSManaged var createdDate: Date
    @NSManaged var dueDate: Date?
    @NSManaged var completedDate: Date?
    
    
    /// Check if task belongs to the given date
    func belongsToDate(_ date: Date) -> Bool {
        Calendar.current.isDate(createdDate, inSameDayAs: date)
    }
    
    /// Check if task should still be shown (created today)
    func isValid(relativeTo currentDate: Date = Date()) -> Bool {
        Calendar.current.isDate(createdDate, inSameDayAs: currentDate)
    }
}

// MARK: - Convenience Extension
extension TaskEntity {
    static let entityName = "TaskEntity"
    
    static func createFetchRequest() -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: Self.entityName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdDate, ascending: false)]
        return request
    }
    
    static func createTodayFetchRequest() -> NSFetchRequest<TaskEntity> {
        let request = NSFetchRequest<TaskEntity>(entityName: Self.entityName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdDate, ascending: false)]
        return request
    }
}
