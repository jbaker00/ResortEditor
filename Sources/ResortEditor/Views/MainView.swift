import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ResortViewModel()
    @State private var selectedResort: Resort?
    @State private var showingAddForm = false

    var body: some View {
        NavigationSplitView {
            ResortListView(
                viewModel: viewModel,
                selectedResort: $selectedResort,
                showingAddForm: $showingAddForm
            )
        } detail: {
            if let resort = selectedResort {
                ResortFormView(resort: resort) { saved in
                    if let saved {
                        Task { await viewModel.save(saved) }
                    }
                    selectedResort = nil
                }
                .id(resort.id)
            } else {
                ContentUnavailableView(
                    "No Resort Selected",
                    systemImage: "mountain.2",
                    description: Text("Select a resort from the list or add a new one.")
                )
            }
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
        .sheet(isPresented: $showingAddForm) {
            NavigationStack {
                ResortFormView(resort: nil) { saved in
                    if let saved {
                        Task { await viewModel.save(saved) }
                    }
                    showingAddForm = false
                }
            }
        }
    }
}
