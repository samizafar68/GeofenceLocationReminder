import SwiftUI
import CoreLocation

struct CreateReminderSheet: View {
    // MARK: - Properties
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var remindersVM: RemindersViewModel
    @State private var radius: Double = 200
    @State private var note: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if let poi = mapVM.selectedPOI {
                    Text(poi.name)
                        .font(.title2)
                        .bold()
                    Text(poi.displayCategory)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    RadiusSelector(radius: $radius)
                    TextField("Note (optional)", text: $note)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    Text("No place selected")
                        .padding()
                }
            }
            .padding(.top)
            .navigationBarTitle("Create Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    mapVM.showingCreateSheet = false
                },
                trailing: Button("Save") {
                    guard let poi = mapVM.selectedPOI else { return }
                    remindersVM.addReminder(
                        name: poi.name,
                        coordinate: poi.coordinate,
                        radius: radius,
                        note: note
                    )
                    mapVM.showingCreateSheet = false
                }
            )
        }
    }
}

