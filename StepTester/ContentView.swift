import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var hm = HealthManager()
    @State private var log: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            Button("Request Health Permissions") {
                hm.requestAuthorization { ok in
                    append("Auth: \(ok ? "granted" : "denied")")
                }
            }

            Button("Write 1000 steps in the last 10 minutes") {
                let end = Date()
                let start = Calendar.current.date(byAdding: .minute, value: -10, to: end)!
                hm.writeSteps(1000, start: start, end: end) { ok in
                    append("Write 1000 steps: \(ok ? "success" : "failed")")
                }
            }

            Button("Fetch recent step samples") {
                hm.fetchRecentSamples { samples in
                    if samples.isEmpty { append("No samples found") }
                    for s in samples.prefix(5) {
                        let steps = Int(s.quantity.doubleValue(for: .count()))
                        append("Sample: \(steps) steps, \(s.startDate.formatted()) → \(s.endDate.formatted())")
                    }
                }
            }

            List(log, id: \.self) { Text($0).font(.footnote) }
        }
        .padding()
    }

    private func append(_ msg: String) {
        DispatchQueue.main.async {
            log.insert(msg, at: 0)
        }
    }
}

