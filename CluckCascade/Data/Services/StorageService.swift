import Foundation

protocol StorageServicing {
    func set<T: Codable>(_ value: T, forKey key: String)
    func value<T: Codable>(forKey key: String, default defaultValue: T) -> T
    func removeValue(forKey key: String)
    func clear()
}

final class StorageService: StorageServicing {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func set<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func value<T: Codable>(forKey key: String, default defaultValue: T) -> T {
        guard let data = defaults.data(forKey: key), let decoded = try? decoder.decode(T.self, from: data) else {
            return defaultValue
        }
        return decoded
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func clear() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}



