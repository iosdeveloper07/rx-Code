//
//  UserDefaultsManager.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}

    private let isLoggedInKey = "app_isLoggedIn"

    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: isLoggedInKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isLoggedInKey)
        }
    }
}
