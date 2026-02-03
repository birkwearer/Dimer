import SwiftUI
import Combine
import ServiceManagement

@main
struct DimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        // Menu bar extra that shows the countdown timer
        MenuBarExtra {
            MenuBarView()
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App Delegate for background behavior

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Always enable launch at login
        if SMAppService.mainApp.status != .enabled {
            try? SMAppService.mainApp.register()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when window is closed - keep running in menu bar
        return false
    }
}

// MARK: - Menu Bar Label (shows in menu bar)

struct MenuBarLabel: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if let data = LifeTimerManager.shared.load() {
                let remaining = LifeTimerData.formattedTimeRemaining(from: data.expectedDeathDate.timeIntervalSince(currentTime))
                Text(String(format: "%d:%02d:%02d:%02d", remaining.days, remaining.hours, remaining.minutes, remaining.seconds))
                    .font(.system(.body, design: .monospaced))
            } else {
                Image(systemName: "timer")
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Menu Bar View (dropdown content)

struct MenuBarView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let data = LifeTimerManager.shared.load() {
                let remaining = LifeTimerData.formattedTimeRemaining(from: data.expectedDeathDate.timeIntervalSince(currentTime))
                
                // Timer display section
                VStack(spacing: 4) {
                    Text("Time Remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%d:%02d:%02d:%02d", remaining.days, remaining.hours, remaining.minutes, remaining.seconds))
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Menu items - GitHub Copilot style
                MenuButton(title: "Open Dimer") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                
                MenuButton(title: "Quit Dimer") {
                    NSApplication.shared.terminate(nil)
                }
            } else {
                Text("No timer set")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                
                Divider()
                    .padding(.vertical, 4)
                
                MenuButton(title: "Open Dimer to set up") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                
                MenuButton(title: "Quit Dimer") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: 200)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - GitHub Copilot Style Menu Button

struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovered ? Color.primary.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
