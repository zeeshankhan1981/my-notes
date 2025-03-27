import SwiftUI

struct DesignSystem {
    // Colors
    struct ColorPalette {
        // Background Colors
        static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let secondaryBackground = Color(red: 0.96, green: 0.96, blue: 0.97)
        static let tertiaryBackground = Color(red: 0.94, green: 0.94, blue: 0.95)
        
        // Text Colors
        static let textPrimary = Color(red: 0.13, green: 0.13, blue: 0.13)
        static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.45)
        static let textTertiary = Color(red: 0.65, green: 0.65, blue: 0.65)
        
        // Power Blue Theme Colors
        static let accent = Color(red: 0.0, green: 0.52, blue: 0.93)
        static let accentLight = Color(red: 0.7, green: 0.85, blue: 0.98)
        static let accentDark = Color(red: 0.0, green: 0.4, blue: 0.8)
        
        // Other UI Colors
        static let separator = Color(red: 0.85, green: 0.85, blue: 0.85)
        static let cardBackground = Color.white
        static let selection = accent.opacity(0.15)
        
        // Status Colors
        static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
        static let warning = Color(red: 0.9, green: 0.6, blue: 0.0)
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
        
        // Tag Colors - Harmonized with Power Blue Theme
        static let tagColors: [Color] = [
            accent,                                     // Power Blue
            Color(red: 0.2, green: 0.6, blue: 0.86),    // Light Blue
            Color(red: 0.4, green: 0.68, blue: 0.8),    // Sky Blue
            Color(red: 0.0, green: 0.7, blue: 0.7),     // Teal
            Color(red: 0.0, green: 0.6, blue: 0.5),     // Green-Blue
            Color(red: 0.3, green: 0.5, blue: 0.8),     // Indigo
            Color(red: 0.5, green: 0.4, blue: 0.9)      // Purple
        ]
    }
    
    // Typography - Bear-like font styles
    struct Typography {
        // Base font families (using system fonts to approximate Bear's typography)
        static let titleFont = Font.system(size: 28, weight: .semibold)
        static let headingFont = Font.system(size: 20, weight: .semibold)
        static let bodyFont = Font.system(size: 16, weight: .regular)
        static let captionFont = Font.system(size: 13, weight: .regular)
        static let smallCaptionFont = Font.system(size: 11, weight: .regular)
        static let monospacedFont = Font.system(size: 15, weight: .regular).monospaced()
        
        // Specific text styles
        static let noteTitle = titleFont
        static let noteHeading = headingFont
        static let noteBody = bodyFont
        static let noteCaption = captionFont
        static let noteMetadata = smallCaptionFont
        static let noteTag = captionFont
    }
    
    // Spacing - Bear uses consistent spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Specific UI element spacing
        static let noteContentPadding: CGFloat = 20
        static let noteTitleBottomPadding: CGFloat = 24
        static let paragraphSpacing: CGFloat = 8
        static let metadataTopPadding: CGFloat = 32
        static let tagSpacing: CGFloat = 6
    }
    
    // Corner Radius
    struct Radius {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
    }
    
    // Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
    
    // Shadow Values
    struct Shadow {
        static let sm = ShadowStyle(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let md = ShadowStyle(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let lg = ShadowStyle(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // Shadow Style Helper
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}
