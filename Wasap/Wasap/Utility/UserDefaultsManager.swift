//
//  UserDefaultsManager.swift
//  Wasap
//
//  Created by chongin on 11/19/24.
//

import Foundation

final public class UserDefaultsManager {
    static public let shared = UserDefaultsManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    public enum KeyCases: String {
        case isFirstLaunch
    }

    public func get<T: Codable>(_ keyCase: KeyCases) -> T? {
        guard let data = userDefaults.data(forKey: keyCase.rawValue) else { return nil }
        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(T.self, from: data)
            return value
        } catch {
            Log.error("Error decoding UserDefaults value for key \(keyCase.rawValue): \(error)")
            return nil
        }
    }

    public func set<T: Codable>(value: T, forKey keyCase: KeyCases) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: keyCase.rawValue)
        } catch {
            Log.error("Error encoding value for UserDefaults key \(keyCase.rawValue): \(error)")
        }
    }
}
