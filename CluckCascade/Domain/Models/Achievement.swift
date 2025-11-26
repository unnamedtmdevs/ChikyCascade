import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    enum Category: String, Codable {
        case progression
        case skill
        case collection
        case streak
    }

    let id: UUID
    var title: String
    var description: String
    var category: Category
    var iconName: String
    var unlockedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: Category,
        iconName: String,
        unlockedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.iconName = iconName
        self.unlockedDate = unlockedDate
    }
}



