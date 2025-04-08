//
//  DatabaseService.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

class DatabaseService {
    static let shared = DatabaseService()
    var realm: Realm?

    private init() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                    }
                }
            )
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            print("Realm Path: \(realm?.configuration.fileURL?.absoluteString ?? "Not found")")
        } catch let error {
            print("Error initializing Realm: \(error.localizedDescription)")
            realm = nil
        }
    }

    func saveOrUpdatePosts(_ postsDecodable: [PostDecodable]) {
        guard let realm = realm else {
            print("Realm not available")
            return
        }
        do {
            try realm.write {
                for postDecodable in postsDecodable {
                    if let existingPost = realm.object(ofType: Post.self, forPrimaryKey: postDecodable.id) { // update
                        existingPost.userId = postDecodable.userId
                        existingPost.title = postDecodable.title
                        existingPost.body = postDecodable.body
                        existingPost.lastUpdated = Date()
                        realm.add(existingPost, update: .modified)
                    } else {
                        // Save
                        let newPost = Post(from: postDecodable)
                        realm.add(newPost, update: .modified)
                    }
                }
                print("\(postsDecodable.count)")
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }

    func getAllPosts() -> Observable<Results<Post>> {
        guard let realm = realm else { return .empty() }
        let results = realm.objects(Post.self).sorted(byKeyPath: "id", ascending: true)
        return Observable.collection(from: results)
    }

    func getFavoritePosts() -> Observable<Results<Post>> {
        guard let realm = realm else { return .empty() }
        let results = realm.objects(Post.self).filter("isFavorite == true").sorted(byKeyPath: "id", ascending: true)
        return Observable.collection(from: results)
    }

    func toggleFavoriteStatus(postId: Int) {
        guard let realm = realm else { return }
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else {
            return
        }

        do {
            try realm.write {
                post.isFavorite.toggle()
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }

    func setFavoriteStatus(postId: Int, isFavorite: Bool) {
        guard let realm = realm else { return }
        guard let post = realm.object(ofType: Post.self, forPrimaryKey: postId) else {
             return
        }

        if post.isFavorite == isFavorite { return } // No change needed

        do {
            try realm.write {
                post.isFavorite = isFavorite
            }
        } catch let error {
        }
    }

    func deleteAllPosts() {
        guard let realm = realm else { return }
        do {
            try realm.write {
                let allPosts = realm.objects(Post.self)
                realm.delete(allPosts)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
