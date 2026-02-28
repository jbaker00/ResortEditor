import SwiftUI

struct ResortListView: View {
    @ObservedObject var viewModel: ResortViewModel
    @Binding var selectedResort: Resort?
    @Binding var showingAddForm: Bool
    @EnvironmentObject var authService: AuthService

    var body: some View {
        List(selection: $selectedResort) {
            ForEach(viewModel.resorts) { resort in
                NavigationLink(value: resort) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(resort.name)
                            .font(.headline)
                        Text("\(resort.city), \(resort.country)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                Task { await viewModel.delete(at: offsets) }
            }
        }
        .navigationTitle("Resorts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddForm = true }) {
                    Label("Add Resort", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            }
        }
        .overlay {
            if viewModel.resorts.isEmpty {
                ContentUnavailableView(
                    "No Resorts",
                    systemImage: "mountain.2",
                    description: Text("Tap + to add the first resort.")
                )
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
