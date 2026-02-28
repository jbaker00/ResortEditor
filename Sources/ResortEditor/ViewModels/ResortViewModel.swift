import Foundation
import FirebaseFirestore

@MainActor
class ResortViewModel: ObservableObject {
    @Published var resorts: [Resort] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListening() {
        listener = db.collection("Resorts")
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let snapshot else { return }
                do {
                    self.resorts = try snapshot.documents.compactMap {
                        try $0.data(as: Resort.self)
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func save(_ resort: Resort) async {
        errorMessage = nil
        do {
            if let id = resort.id {
                try await db.collection("Resorts").document(id).setData(resort.dictionary)
            } else {
                try await db.collection("Resorts").addDocument(data: resort.dictionary)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ resort: Resort) async {
        guard let id = resort.id else { return }
        errorMessage = nil
        do {
            try await db.collection("Resorts").document(id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) async {
        let toDelete = offsets.map { resorts[$0] }
        for resort in toDelete {
            await delete(resort)
        }
    }
}
