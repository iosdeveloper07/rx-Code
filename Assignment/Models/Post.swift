//
//  Post.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import RealmSwift

struct PostDecodable: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class Post: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var userId: Int = 0
    @Persisted var title: String = ""
    @Persisted var body: String = ""
    @Persisted var isFavorite: Bool = false
    @Persisted var lastUpdated: Date = Date()

    convenience init(from decodable: PostDecodable, isFavorite: Bool = false) {
        self.init()
        self.id = decodable.id
        self.userId = decodable.userId
        self.title = decodable.title
        self.body = decodable.body
        self.isFavorite = isFavorite
        self.lastUpdated = Date()
    }
}
