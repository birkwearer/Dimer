import Foundation

struct LifeTimerData: Codable {
    // ...existing code...
    var birthday: Date
    var expectedAge: Int
    
    var expectedDeathDate: Date {
        Calendar.current.date(byAdding: .year, value: expectedAge, to: birthday) ?? birthday
    }
    
    var timeRemaining: TimeInterval {
        expectedDeathDate.timeIntervalSince(Date())
    }
    
    var isExpired: Bool {
        timeRemaining <= 0
    }
    
    static func formattedTimeRemaining(from timeInterval: TimeInterval) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard timeInterval > 0 else {
            return (0, 0, 0, 0)
        }
        
        let totalSeconds = Int(timeInterval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return (days, hours, minutes, seconds)
    }
}

class LifeTimerManager {
    static let shared = LifeTimerManager()
    
    private let userDefaultsKey = "lifeTimerData"
    private let appGroupIdentifier = "group.Boundrel.Dimer"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    func save(_ data: LifeTimerData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        sharedDefaults?.set(encoded, forKey: userDefaultsKey)
        sharedDefaults?.synchronize()
    }
    
    func load() -> LifeTimerData? {
        sharedDefaults?.synchronize()
        guard let data = sharedDefaults?.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(LifeTimerData.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func clear() {
        sharedDefaults?.removeObject(forKey: userDefaultsKey)
        sharedDefaults?.synchronize()
    }
}
