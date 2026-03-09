import Foundation
import CoreData
import UserNotifications

class PersistenceController {
    static let shared = PersistenceController()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TaskModel")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Merge policy for conflict resolution
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save
    func save() {
        let context = viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch All Tasks
    func fetchAllTasks() -> [TaskEntity] {
        let request = TaskEntity.createFetchRequest()
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Toggle task
    func toggleTask(_ task: NSManagedObject) {
        let isCompleted = task.value(forKey: "isCompleted") as? Bool ?? false
        task.setValue(!isCompleted, forKey: "isCompleted")
        task.setValue(!isCompleted ? Date() : nil, forKey: "completedDate")
        
        // Cancel notification if task is completed
        if !isCompleted {
            if let taskId = task.value(forKey: "id") as? String {
                NotificationManager.shared.cancelNotification(taskId: taskId)
            }
        }
        
        save()
    }
    
    // MARK: - Fetch Today's Tasks
    func fetchTodayTasks() -> [TaskEntity] {
        let allTasks = fetchAllTasks()
        let today = Date()
        
        // Filter only today's tasks
        return allTasks.filter { $0.isValid(relativeTo: today) }
    }
    
    // MARK: - Add Task
    func addTask(title: String, description: String = "", dueTime: Date? = nil) {
        let newTask = TaskEntity(context: viewContext)
        let taskId = UUID()
        newTask.id = taskId
        newTask.title = title
        newTask.taskDescription = description
        newTask.isCompleted = false
        newTask.createdDate = Date()
        newTask.dueDate = dueTime
        newTask.completedDate = nil
        
        save()
        
        if let dueTime = dueTime {
            NotificationManager.shared.scheduleTaskNotification(taskId: taskId.uuidString, taskTitle: title, dueDate: dueTime)
        }
    }
    
    // MARK: - Toggle Completion
    func toggleTaskCompletion(_ task: TaskEntity) {
        task.isCompleted.toggle()
        task.completedDate = task.isCompleted ? Date() : nil
        save()
    }
    
    // MARK: - Delete Task
    func deleteTask(_ task: TaskEntity) {
        viewContext.delete(task)
        save()
    }
    
    // MARK: - Delete All Expired Tasks
    func deleteExpiredTasks() {
        let allTasks = fetchAllTasks()
        let today = Date()
        
        for task in allTasks {
            if !task.isValid(relativeTo: today) {
                viewContext.delete(task)
            }
        }
        
        save()
    }
    
    // MARK: - Delete All Tasks
//    func deleteAllTasks() {
//        let request = TaskEntity.createFetchRequest()
//        
//        do {
//            let tasks = try viewContext.fetch(request)
//            for task in tasks {
//                viewContext.delete(task)
//            }
//            save()
//        } catch {
//            print("Error deleting all tasks: \(error)")
//        }
//    }
    
    func deleteTask(_ task: NSManagedObject) {
        // Cancel notification
        if let taskId = task.value(forKey: "id") as? String {
            NotificationManager.shared.cancelNotification(taskId: taskId)
        }
        
        viewContext.delete(task)
        save()
    }
    
}
