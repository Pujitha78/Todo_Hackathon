import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    @State private var tasks: [NSManagedObject] = []
    @State private var selectedTab = 0
    @State private var showAdd = false
    @State private var title = ""
    @State private var description = ""
    @State private var setTime = false
    @State private var dueTime = Date()
    @State private var notificationMessage = ""
    @State private var showNotificationAlert = false
    @State private var refreshID = UUID()
    
    let manager = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Header with Counter
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today")
                            .font(.system(size: 32, weight: .bold))
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Counter at Top Right
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("\(completedCount)")
                                .font(.title2.bold())
                                .foregroundColor(.green)
                            Text("of \(totalTasksCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: totalTasksCount > 0 ? Double(completedCount) / Double(totalTasksCount) : 0)
                            .frame(width: 100)
                            .tint(.green)
                    }
                }
                .padding()
                
                Divider()
                
                // MARK: - Tab Picker
                Picker("View", selection: $selectedTab) {
                    Label("Active", systemImage: "checkmark.circle").tag(0)
                    Label("All", systemImage: "list.bullet").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // MARK: - Task List
                if filteredTasks.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.green.opacity(0.3))
                        Text(selectedTab == 0 ? "No active tasks!" : "All done for today!")
                            .font(.title2.bold())
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredTasks, id: \.objectID) { task in
                            TaskRowView(
                                task: task,
                                manager: manager,
                                notificationManager: notificationManager,
                                onTaskUpdated: {
                                    loadTasks()
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .id(refreshID)
                }
            }
            
            // MARK: - Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 2)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            notificationManager.requestPermission()
            notificationManager.scheduleEndOfDayNotification()
            loadTasks()
        }
        .sheet(isPresented: $showAdd) {
            addTaskSheet
        }
        .alert("Reminder Scheduled", isPresented: $showNotificationAlert) {
            Button("OK") { }
        } message: {
            Text(notificationMessage)
        }
    }
    
    // MARK: - Add Task Sheet
    
    var addTaskSheet: some View {
        VStack(spacing: 20) {
            HStack {
                Text("New Task")
                    .font(.title2.bold())
                Spacer()
                Button(action: { closeAddSheet() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 12) {
                // Task Title
                VStack(alignment: .leading, spacing: 4) {
                    Label("Task Title", systemImage: "doc.text")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    TextField("What needs to be done?", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Label("Description (Optional)", systemImage: "doc.text.fill")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    TextField("Add details...", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                }
                
                // Time Settings
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $setTime) {
                        Label("Set Reminder Time", systemImage: "bell")
                            .font(.caption.bold())
                    }
                    
                    if setTime {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Due Time (Today)", systemImage: "clock")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            DatePicker(
                                "Select Time",
                                selection: $dueTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.caption)
                                Text("Notification will arrive at \(formatTime(dueTime))")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
            }
            .padding()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: { closeAddSheet() }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                
                Button(action: { addTask() }) {
                    Text("Add Task")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(title.isEmpty)
            }
            .padding()
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    /// All tasks (includes completed and incomplete)
    var allTasks: [NSManagedObject] {
        tasks
    }
    
    /// Total count of all tasks
    var totalTasksCount: Int {
        allTasks.count
    }
    
    /// Count of completed tasks
    var completedCount: Int {
        allTasks.filter { ($0.value(forKey: "isCompleted") as? Bool) ?? false }.count
    }
    
    /// Filtered tasks based on selected tab
    var filteredTasks: [NSManagedObject] {
        if selectedTab == 0 {
            // Active tab: only incomplete tasks
            return tasks.filter { ($0.value(forKey: "isCompleted") as? Bool) ?? false == false }
        } else {
            // All tab: all tasks
            return tasks
        }
    }
    
    // MARK: - Helper Methods
    
    /// Add new task
    private func addTask() {
        guard !title.isEmpty else { return }
        
        manager.addTask(
            title: title,
            description: description,
            dueTime: setTime ? dueTime : nil
        )
        
        if setTime {
            notificationMessage = "Reminder set for \(formatTime(dueTime))"
            showNotificationAlert = true
        }
        
        loadTasks()
        closeAddSheet()
    }
    
    /// Load tasks from database
    private func loadTasks() {
        tasks = manager.fetchTodayTasks()
        refreshID = UUID()
    }
    
    /// Close add task sheet and reset form
    private func closeAddSheet() {
        title = ""
        description = ""
        setTime = false
        dueTime = Date()
        showAdd = false
    }
    
    /// Format time for display
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
