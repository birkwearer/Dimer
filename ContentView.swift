import SwiftUI
import Combine

struct ContentView: View {
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var expectedAge: Int = 80
    @State private var isSetup: Bool = false
    @State private var lifeTimerData: LifeTimerData?
    @State private var currentTime: Date = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Date range: from 120 years ago to today (no future birthdays)
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let oldest = calendar.date(byAdding: .year, value: -120, to: Date()) ?? Date()
        let today = Date()
        return oldest...today
    }
    
    var body: some View {
        NavigationStack {
            if isSetup, let data = lifeTimerData {
                timerView(data: data)
            } else {
                setupView
            }
        }
        .onAppear {
            loadSavedData()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var setupView: some View {
        VStack(spacing: 20) {
            // Birthday input
            HStack(spacing: 16) {
                Text("Enter your birthday")
                    .font(.headline)
                
                Spacer()
                
                DatePicker("", selection: $birthday, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(.field)
                    .labelsHidden()
                    .fixedSize()
            }

            // Expected lifespan input
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Expected lifespan")
                        .font(.headline)
                    Text("How long do you expect to live?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Stepper(value: $expectedAge, in: 30...120) {
                    Text("\(expectedAge) years")
                        .font(.body)
                        .monospacedDigit()
                        .frame(width: 80, alignment: .trailing)
                }
                .fixedSize()
            }

            Button(action: saveAndStart) {
                Text("Start Timer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: 700)
        .navigationTitle("Dimer")
    }
    
    private func timerView(data: LifeTimerData) -> some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("Time Remaining")
                    .font(.title2)
                    .foregroundColor(.secondary)
                let remaining = LifeTimerData.formattedTimeRemaining(from: data.expectedDeathDate.timeIntervalSince(currentTime))
                Text(String(format: "%d:%02d:%02d:%02d", remaining.days, remaining.hours, remaining.minutes, remaining.seconds))
                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 6)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Birthday")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(data.birthday, format: .dateTime.month().day().year())
                        .font(.body)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Expected Age")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(data.expectedAge) years")
                        .font(.body)
                }
            }

            HStack(spacing: 12) {
                Button("Reset") { resetTimer() }
                    .buttonStyle(.bordered)
                    .tint(.red)

                Spacer()
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .navigationTitle("Dimer")
    }
    
    private func saveAndStart() {
        let data = LifeTimerData(birthday: birthday, expectedAge: expectedAge)
        LifeTimerManager.shared.save(data)
        lifeTimerData = data
        isSetup = true
    }
    
    private func loadSavedData() {
        if let data = LifeTimerManager.shared.load() {
            lifeTimerData = data
            birthday = data.birthday
            expectedAge = data.expectedAge
            isSetup = true
        }
    }
    
    private func resetTimer() {
        LifeTimerManager.shared.clear()
        lifeTimerData = nil
        birthday = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        expectedAge = 80
        isSetup = false
    }
}

struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .minimumScaleFactor(0.5)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 50)
    }
}

#Preview {
    ContentView()
}
