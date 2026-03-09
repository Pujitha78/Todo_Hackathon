//import SwiftUI
//
//struct Home: View {
//    @StateObject private var viewModel = TaskViewModel()
//    @State private var showAddTask = false
//    @State private var selectedTab = 0
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                // Header with progress
//                VStack(alignment: .leading, spacing: 16) {
//                    HStack {
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Today")
//                                .font(.system(size: 32, weight: .bold))
//                            Text(formattedDate)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                        VStack(alignment: .trailing, spacing: 8) {
//                            HStack(spacing: 4) {
//                                Text("\(viewModel.completedCount)")
//                                    .font(.title2.bold())
//                                Text("of \(viewModel.todayCount)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            ProgressView(value: viewModel.completionPercentage)
//                                .frame(width: 100)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 16)
//                }
//                .background(Color(.systemBackground))
//                
//                Divider()
//                
//                // Tab view
//                Picker("View", selection: $selectedTab) {
//                    Label("Active", systemImage: "checkmark.circle").tag(0)
//                    Label("All", systemImage: "list.bullet").tag(1)
//                }
//                .pickerStyle(.segmented)
//                .padding()
//                
//                // Task list
//                if viewModel.tasks.isEmpty {
//                    EmptyStateView()
//                } else {
//                    taskListView
//                }
//                
//                Spacer()
//            }
//        }
//        .onAppear {
//            viewModel.fetchTodayTasks()
//        }
//        .sheet(isPresented: $showAddTask) {
//            AddTaskView { title, description, dueTime in
//                viewModel.addTask(title, description: description, dueTime: dueTime)
//            }
//        }
//        .floatingActionButton(action: { showAddTask = true })
//    }
//    
//    @ViewBuilder
//    private var taskListView: some View {
//        List {
//            if selectedTab == 0 {
//                // Show only incomplete tasks
//                ForEach(viewModel.incompleteTasks, id: \.objectID) { task in
//                    TaskRowView(
//                        task: task,
//                        onToggle: {
//                            withAnimation {
//                                viewModel.toggleTaskCompletion(task)
//                            }
//                        },
//                        onDelete: {
//                            viewModel.deleteTask(task)
//                        }
//                    )
//                }
//            } else {
//                // Show all tasks
//                Section("Incomplete") {
//                    ForEach(viewModel.incompleteTasks, id: \.objectID) { task in
//                        TaskRowView(
//                            task: task,
//                            onToggle: {
//                                withAnimation {
//                                    viewModel.toggleTaskCompletion(task)
//                                }
//                            },
//                            onDelete: {
//                                viewModel.deleteTask(task)
//                            }
//                        )
//                    }
//                }
//                
//                if !viewModel.completedTasks.isEmpty {
//                    Section("Completed") {
//                        ForEach(viewModel.completedTasks, id: \.objectID) { task in
//                            TaskRowView(
//                                task: task,
//                                onToggle: {
//                                    withAnimation {
//                                        viewModel.toggleTaskCompletion(task)
//                                    }
//                                },
//                                onDelete: {
//                                    viewModel.deleteTask(task)
//                                }
//                            )
//                        }
//                    }
//                }
//            }
//        }
//        .listStyle(.insetGrouped)
//    }
//    
//    private var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        return formatter.string(from: Date())
//    }
//}
//
////#Preview {
////    ContentView()
////}
