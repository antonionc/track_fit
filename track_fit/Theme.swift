import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct Theme {
    struct Colors {
        static let primaryAccent = Color.blue
        
        static let background = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)
                : UIColor.systemGroupedBackground
        })
        
        static let cardBackground = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.05)
                : UIColor.white
        })
        
        static let cardBorder = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.2)
                : UIColor(white: 0.0, alpha: 0.1)
        })
    }
}

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.Colors.cardBackground)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: colorScheme == .light ? Color.black.opacity(0.05) : Color.clear, radius: 5, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}
