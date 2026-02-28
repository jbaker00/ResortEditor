import SwiftUI

struct ResortFormView: View {
    let onDismiss: (Resort?) -> Void

    @State private var name: String
    @State private var image: String
    @State private var description: String
    @State private var city: String
    @State private var country: String
    @State private var category: String
    @State private var airport: String
    @State private var url: String

    private let existingId: String?
    private let isNew: Bool

    init(resort: Resort?, onDismiss: @escaping (Resort?) -> Void) {
        self.onDismiss = onDismiss
        self.isNew = resort == nil
        self.existingId = resort?.id
        _name = State(initialValue: resort?.name ?? "")
        _image = State(initialValue: resort?.image ?? "")
        _description = State(initialValue: resort?.description ?? "")
        _city = State(initialValue: resort?.city ?? "")
        _country = State(initialValue: resort?.country ?? "")
        _category = State(initialValue: resort?.category ?? "")
        _airport = State(initialValue: resort?.airport ?? "")
        _url = State(initialValue: resort?.url ?? "")
    }

    var body: some View {
        Form {
            Section("Basic Info") {
                LabeledContent("Name") {
                    TextField("Resort name", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Category") {
                    TextField("e.g. Beach, Ski, Golf", text: $category)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Location") {
                LabeledContent("City") {
                    TextField("City", text: $city)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Country") {
                    TextField("Country", text: $country)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Airport") {
                    TextField("IATA code", text: $airport)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Media & Links") {
                LabeledContent("Image URL") {
                    TextField("https://...", text: $image)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Website URL") {
                    TextField("https://...", text: $url)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Description") {
                TextEditor(text: $description)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(isNew ? "New Resort" : name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onDismiss(nil) }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let resort = Resort(
                        id: existingId,
                        name: name,
                        image: image,
                        description: description,
                        city: city,
                        country: country,
                        category: category,
                        airport: airport,
                        url: url
                    )
                    onDismiss(resort)
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
