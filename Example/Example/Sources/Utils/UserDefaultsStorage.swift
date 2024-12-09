//
//  UserDefaultsStorage.swift
//  Example
//
//  Created by Andrii Vysotskyi on 13.11.2024.
//

import Foundation

// swiftlint:disable force_cast force_unwrapping

/// A property wrapper type that reflects a value from `UserDefaults`.
@propertyWrapper
struct UserDefaultsStorage<Value> {

    fileprivate init(storage: Storage) { // swiftlint:disable:this strict_fileprivate
        self.storage = storage
    }

    var wrappedValue: Value {
        get { storage.get() as! Value }
        nonmutating set { storage.set(newValue) }
    }

    // MARK: - Private Properties

    private let storage: Storage
}

private struct Storage {

    /// Writes value to storage.
    let get: () -> Any

    /// Writes value to storage.
    let set: (Any) -> Void
}

extension UserDefaultsStorage {

    /// Creates a property that can read and write to a string user default.
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == String {
        store.register(defaults: [key: wrappedValue])
        let storage = Storage {
            store.string(forKey: key)!
        } set: { newValue in
            store.set(newValue as! String, forKey: key)
        }
        self.init(storage: storage)
    }

    /// Creates a property that can read and write to a codable user default.
    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value: Codable {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(wrappedValue)
            store.register(defaults: [key: data])
        } catch {
            assertionFailure("Unable to register default value: \(error).")
        }
        let storage = Storage {
            do {
                let data = store.data(forKey: key)!
                return try JSONDecoder().decode(Value.self, from: data)
            } catch {
                return wrappedValue
            }
        } set: { newValue in
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue as! Value)
                store.set(data, forKey: key)
            } catch {
                assertionFailure("Unable to save new value.")
            }
        }
        self.init(storage: storage)
    }
}

extension UserDefaultsStorage where Value: ExpressibleByNilLiteral {

    /// Creates a property that can read and write an Optional string user
    /// default.
    init(wrappedValue: Value = nil, _ key: String, store: UserDefaults = .standard) where Value == String? {
        if let wrappedValue {
            store.register(defaults: [key: wrappedValue])
        }
        let storage = Storage {
            store.string(forKey: key) as Any
        } set: { newValue in
            if let newValue = newValue as? String {
                store.set(newValue, forKey: key)
            } else {
                store.removeObject(forKey: key)
            }
        }
        self.init(storage: storage)
    }
}

// swiftlint:enable force_cast force_unwrapping
