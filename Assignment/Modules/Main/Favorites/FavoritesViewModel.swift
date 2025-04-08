//
//  FavoritesViewModel.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class FavoritesViewModel {

    let favoritePosts: BehaviorRelay<[Post]> = BehaviorRelay(value: [])
    let isEmpty: Observable<Bool>

    private let databaseService: DatabaseService
    private let disposeBag = DisposeBag()
    private var notificationToken: NotificationToken?

    init(databaseService: DatabaseService = .shared) {
        self.databaseService = databaseService

        isEmpty = favoritePosts.asObservable()
             .map { $0.isEmpty }
             .distinctUntilChanged()

        observeFavoriteChanges()
    }

    func unfavoritePost(postId: Int) {
        databaseService.setFavoriteStatus(postId: postId, isFavorite: false)
    }

    private func observeFavoriteChanges() {
        guard let realm = databaseService.realm else { return }

        let favoriteResults = realm.objects(Post.self)
                                  .filter("isFavorite == true")
                                  .sorted(byKeyPath: "id", ascending: true)

        notificationToken = favoriteResults.observe { [weak self] (changes: RealmCollectionChange) in
             guard let self = self else { return }
             switch changes {
             case .initial(let favPosts):
                 print("\(favPosts.count)")
                 self.favoritePosts.accept(Array(favPosts))
             case .update(let favPosts, _, _, _):
                 print("\(favPosts.count)")
                 self.favoritePosts.accept(Array(favPosts))
             case .error(let error):
                 print("\(error.localizedDescription)")
             }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}
