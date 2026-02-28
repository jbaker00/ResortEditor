import Foundation
import FirebaseFirestore

struct Resort: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var image: String
    var description: String
    var city: String
    var country: String
    var category: String
    var airport: String
    var url: String

    init(
        id: String? = nil,
        name: String = "",
        image: String = "",
        description: String = "",
        city: String = "",
        country: String = "",
        category: String = "",
        airport: String = "",
        url: String = ""
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.city = city
        self.country = country
        self.category = category
        self.airport = airport
        self.url = url
    }

    var dictionary: [String: Any] {
        [
            "name": name,
            "image": image,
            "description": description,
            "city": city,
            "country": country,
            "category": category,
            "airport": airport,
            "url": url
        ]
    }
}
