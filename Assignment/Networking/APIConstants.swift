//
//  APIConstants.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation

struct APIConstants {
    static let baseUrl = "https://jsonplaceholder.typicode.com"

    struct Endpoints {
        static let posts = "/posts"
    }

    static func postsUrl() -> String {
        return baseUrl + Endpoints.posts
    }
}
