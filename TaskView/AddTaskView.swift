import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var setTime = false
    @State private var dueTime = Date()
    @State private var isValid = false
    
    let onAdd: (String, String, Date?) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    if #available(iOS 17.0, *) {
                        TextField("Task title", text: $title)
                            .onChange(of: title) { oldValue, newValue in
                                validateForm()
                            }
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Reminder") {
                    Toggle("Set a time", isOn: $setTime)
                    
                    if setTime {
                        DatePicker(
                            "Due time",
                            selection: $dueTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                Section {
                    Button(action: addTask) {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Task")
                            }
                            .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                    .listRowBackground(
                        isValid ? Color.blue : Color.gray.opacity(0.3)
                    )
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func validateForm() {
        isValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func addTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        
        let dueDate = setTime ? dueTime : nil
        
        onAdd(trimmedTitle, trimmedDescription, dueDate)
        dismiss()
    }
}

#Preview {
    AddTaskView { _, _, _ in }
}
