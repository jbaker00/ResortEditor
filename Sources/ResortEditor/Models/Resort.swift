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
    var bookingUrl: String

    init(
        id: String? = nil,
        name: String = "",
        image: String = "",
        description: String = "",
        city: String = "",
        country: String = "",
        category: String = "",
        airport: String = "",
        url: String = "",
        bookingUrl: String = "https://www.expedia.com"
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
        self.bookingUrl = bookingUrl
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
            "url": url,
            "bookingUrl": bookingUrl
        ]
    }

    // Custom decoder so existing documents without bookingUrl still load
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _id = try c.decode(DocumentID<String>.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        image = try c.decode(String.self, forKey: .image)
        description = try c.decode(String.self, forKey: .description)
        city = try c.decode(String.self, forKey: .city)
        country = try c.decode(String.self, forKey: .country)
        category = try c.decode(String.self, forKey: .category)
        airport = try c.decode(String.self, forKey: .airport)
        url = try c.decode(String.self, forKey: .url)
        bookingUrl = (try? c.decode(String.self, forKey: .bookingUrl))
            .flatMap { $0.isEmpty ? nil : $0 }
            ?? "https://www.expedia.com"
    }
}
