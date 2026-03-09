import Foundation
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var completedCount: Int = 0
    @Published var todayCount: Int = 0
    
    private let dateProvider: DateProviding
    private var lastDayCheckDate: Date = Date()
    private let coreDataManager: PersistenceController
    
    init(
        dateProvider: DateProviding = DateProvider(),
        coreDataManager: PersistenceController = PersistenceController.shared
    ) {
        self.dateProvider = dateProvider
        self.coreDataManager = coreDataManager
        self.lastDayCheckDate = dateProvider.now()
    }
    
    /// Fetch today's tasks from the database
    func fetchTodayTasks() {
        // Clean up old tasks if it's a new day
        if dateProvider.isNewDay(lastDayCheckDate) {
            deleteExpiredTasks()
            lastDayCheckDate = dateProvider.now()
        }
        
        // Fetch today's tasks
        let today = dateProvider.now()
        let allTasks = coreDataManager.fetchAllTasks()
        
        // Filter only today's tasks
        self.tasks = allTasks.filter { $0.isValid(relativeTo: today) }
        updateCounts()
    }
    
    /// Add a new task
    func addTask(_ title: String, description: String = "", dueTime: Date? = nil) {
        coreDataManager.addTask(title: title, description: description, dueTime: dueTime)
        fetchTodayTasks()
    }
    
    /// Toggle task completion status
    func toggleTaskCompletion(_ task: TaskEntity) {
        coreDataManager.toggleTaskCompletion(task)
        updateCounts()
    }
    
    /// Delete a task
    func deleteTask(_ task: TaskEntity) {
        coreDataManager.deleteTask(task)
        fetchTodayTasks()
    }
    
    /// Delete all expired tasks from previous days
    private func deleteExpiredTasks() {
        coreDataManager.deleteExpiredTasks()
    }
    
    /// Update completion counts
    private func updateCounts() {
        todayCount = tasks.count
        completedCount = tasks.filter { $0.isCompleted }.count
    }
    
    /// Get completion percentage
    var completionPercentage: Double {
        guard todayCount > 0 else { return 0 }
        return Double(completedCount) / Double(todayCount)
    }
    
    /// Get incomplete tasks
    var incompleteTasks: [TaskEntity] {
        tasks.filter { !$0.isCompleted }
    }
    
    /// Get completed tasks
    var completedTasks: [TaskEntity] {
        tasks.filter { $0.isCompleted }
    }
}
