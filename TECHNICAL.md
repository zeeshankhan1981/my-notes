# Technical Documentation

## Architecture Overview

### Data Model

The core data model is defined in `Note.swift` and consists of:

- `Note`: Main data structure containing:
  - `title`: String
  - `content`: String (rich text)
  - `date`: Date (creation timestamp)
  - `isPinned`: Bool
  - `folder`: String (default "Others")
  - `tags`: [String]
  - `checklist`: [ChecklistItem]
  - `imageData`: Data? (optional image attachment)

- `ChecklistItem`: Supporting structure for checklists within notes
  - `text`: String
  - `isChecked`: Bool

### Data Persistence

The `NotesStore` class handles:
- Loading and saving notes
- Managing the note collection
- Implementing persistence (likely using UserDefaults or CoreData)

### User Interface

The application follows a standard SwiftUI architecture:

- `ContentView`: Main application view showing list of notes
- `AddNoteView`: Interface for creating new notes with:
  - Modern iOS-style checkbox implementation
  - Improved text field styling
  - Enhanced note editing interface
  - Better visual hierarchy
- `NoteDetailView`: Detailed view for viewing and editing notes

## Implementation Details

### UI Components

- Custom `iOSCheckboxToggleStyle` for native iOS checkbox appearance
- Improved text field styling with proper padding and background
- Enhanced note editing interface with better spacing and organization
- Proper image display with aspect ratio and shadow effects

### State Management

The application uses SwiftUI's built-in state management:
- `@State` for local UI state
- `@Binding` for parent-child communication
- `@EnvironmentObject` for global state sharing

### Data Flow

1. User interacts with UI
2. Changes are reflected in SwiftUI views
3. State updates trigger UI refresh
4. Changes are persisted through `NotesStore`

### Error Handling

The application implements:
- Input validation
- Error states in UI
- Safe data persistence operations

## Performance Considerations

- Efficient data loading through lazy loading
- Optimized image handling with proper aspect ratio
- Efficient text rendering
- Memory management for large note collections

## Security

- Data is stored locally on device
- No network communication by default
- Secure coding practices implemented

## Future Enhancements

- Cloud sync capabilities
- Search functionality
- Custom note templates
- Markdown support
- Voice notes
- Dark mode support
