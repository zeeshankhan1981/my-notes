import SwiftUI

struct DesignSystem {
    // Colors
    struct ColorPalette {
        // Background Colors
        static let background = SwiftUI.Color(red: 0.98, green: 0.98, blue: 0.98)
        static let darkBackground = SwiftUI.Color(red: 0.12, green: 0.12, blue: 0.12)
        
        // Text Colors
        static let textPrimary = SwiftUI.Color(red: 0.12, green: 0.12, blue: 0.12)
        static let textSecondary = SwiftUI.Color(red: 0.38, green: 0.38, blue: 0.38)
        
        // Accent Colors
        static let accent = SwiftUI.Color(red: 0.0, green: 0.5, blue: 0.9)
        static let success = SwiftUI.Color(red: 0.2, green: 0.7, blue: 0.3)
        static let warning = SwiftUI.Color(red: 0.9, green: 0.6, blue: 0.0)
        static let error = SwiftUI.Color(red: 0.9, green: 0.2, blue: 0.2)
        
        // Tag Colors
        static let tagColors: [SwiftUI.Color] = [
            SwiftUI.Color(red: 0.98, green: 0.75, blue: 0.75),
            SwiftUI.Color(red: 0.98, green: 0.75, blue: 0.98),
            SwiftUI.Color(red: 0.75, green: 0.75, blue: 0.98),
            SwiftUI.Color(red: 0.75, green: 0.98, blue: 0.98),
            SwiftUI.Color(red: 0.75, green: 0.98, blue: 0.75),
            SwiftUI.Color(red: 0.98, green: 0.98, blue: 0.75)
        ]
    }
    
    // Typography
    struct Typography {
        static let title = Font.system(size: 22, weight: .semibold)
        static let heading = Font.system(size: 18, weight: .medium)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }
    
    // Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // Corner Radius
    struct Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
    }
}
