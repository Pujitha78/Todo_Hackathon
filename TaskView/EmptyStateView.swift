import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 64))
                    .foregroundColor(.blue.opacity(0.3))
                
                VStack(spacing: 4) {
                    Text("All done for today!")
                        .font(.title2.bold())
                    Text("Add a task to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyStateView()
}
