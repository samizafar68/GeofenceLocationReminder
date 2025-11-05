import SwiftUI

// MARK: - Custom Radius Selector
struct RadiusSelector: View {
    @Binding var radius: Double
    let minRadius: Double = 50
    let maxRadius: Double = 1000

    var body: some View {
        VStack(spacing: 8) {
            Text("Radius: \(Int(radius)) m")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(lineWidth: 1)
                    .frame(width: 110, height: 110)
                    .opacity(0.4)
                Text("\(Int(radius)) m")
                    .font(.subheadline)
            }

            Slider(value: $radius, in: minRadius...maxRadius, step: 10)
                .accessibilityLabel("Select radius in meters")
        }
        .padding()
    }
}

