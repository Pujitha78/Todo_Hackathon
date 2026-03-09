import SwiftUI

struct FloatingActionButtonModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: action) {
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
    }
}

extension View {
    func floatingActionButton(action: @escaping () -> Void) -> some View {
        self.modifier(FloatingActionButtonModifier(action: action))
    }
}
