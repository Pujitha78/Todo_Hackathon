import SwiftUI
import CoreData

struct TaskRowView: View {
    let task: NSManagedObject
    let manager: PersistenceController
    let notificationManager: NotificationManager
    var onTaskUpdated: (() -> Void)?
    
    @State private var isCompleted = false
    @State private var isDeleting = false
    
    var body: some View {
        let taskTitle = task.value(forKey: "title") as? String ?? ""
        let taskDesc = task.value(forKey: "taskDescription") as? String ?? ""
        let dueDate = task.value(forKey: "dueDate") as? Date
        
        ZStack {
            // Green background for completed tasks
            if isCompleted && !isDeleting {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.15))
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Show content only if not deleting
            if !isDeleting {
                HStack(spacing: 12) {
                    // Circle/Checkmark Button - Completes task
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            toggleCompletion()
                        }
                    }) {
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                    
                    // Task Content
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(taskTitle)
                                .strikethrough(isCompleted)
                                .foregroundColor(isCompleted ? .green : .primary)
                                .fontWeight(isCompleted ? .regular : .semibold)
                            
                            // Due Time Badge
                            if let dueDate = dueDate {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                    Text(formatTime(dueDate))
                                        .font(.caption)
                                }
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                        
                        // Description
                        if !taskDesc.isEmpty {
                            Text(taskDesc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Delete Button
                    Button(action: {
                        deleteTask()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }
        }
        .onAppear {
            isCompleted = task.value(forKey: "isCompleted") as? Bool ?? false
        }
    }
    
    // MARK: - Private Methods
    
    /// Toggle task completion with green feedback
    private func toggleCompletion() {
        // Immediate UI update
        isCompleted.toggle()
        
        // Update Core Data
        if let completedBool = task.value(forKey: "isCompleted") as? Bool {
            task.setValue(!completedBool, forKey: "isCompleted")
            task.setValue(!completedBool ? Date() : nil, forKey: "completedDate")
            
            // Cancel notification if completing
            if !completedBool {
                if let taskId = task.value(forKey: "id") as? String {
                    notificationManager.cancelNotification(taskId: taskId)
                }
            }
        }
        
        // Save to database
        manager.save()
        
        // Notify parent to refresh and filter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onTaskUpdated?()
        }
    }
    
    /// Delete task with smooth animation
    private func deleteTask() {
        // Animate view away
        withAnimation(.easeInOut(duration: 0.3)) {
            isDeleting = true
        }
        
        // Cancel notification
        if let taskId = task.value(forKey: "id") as? String {
            notificationManager.cancelNotification(taskId: taskId)
        }
        
        // Delete after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                manager.viewContext.delete(task)
                manager.save()
                
                // Notify parent to refresh
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onTaskUpdated?()
                }
            } catch {
                print("Error deleting task: \(error)")
                // Reset if error occurs
                withAnimation {
                    isDeleting = false
                }
            }
        }
    }
    
    /// Format date to time string
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let manager = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    let task = NSEntityDescription.insertNewObject(
        forEntityName: "TaskEntity",
        into: manager.viewContext
    )
    task.setValue(UUID(), forKey: "id")
    task.setValue("Sample Task", forKey: "title")
    task.setValue("This is a sample description", forKey: "taskDescription")
    task.setValue(false, forKey: "isCompleted")
    task.setValue(Date(), forKey: "createdDate")
    
    return List {
        TaskRowView(
            task: task,
            manager: manager,
            notificationManager: notificationManager,
            onTaskUpdated: { print("Task updated") }
        )
    }
}
