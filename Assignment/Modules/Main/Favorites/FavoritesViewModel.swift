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

    private let postStorage: PostStorageProtocol
    private let disposeBag = DisposeBag()
    private var notificationToken: NotificationToken?

    init(postStorage: PostStorageProtocol = DatabaseService.shared) {
        self.postStorage = postStorage

        observeFavoriteChanges()
    }

    func unfavoritePost(postId: Int) {
        postStorage.setFavoriteStatus(postId: postId, isFavorite: false)
    }
    
    private func observeFavoriteChanges() {
        guard let realm = postStorage.realm else { return }

        let favoriteResults = realm.objects(Post.self)
            .filter("isFavorite == true")
            .sorted(byKeyPath: "id", ascending: true)

        notificationToken = favoriteResults.observe { [weak self] (changes: RealmCollectionChange<Results<Post>>) in
            guard let self = self else { return }
            switch changes {
            case .initial(let posts),
                 .update(let posts, _, _, _):
                self.favoritePosts.accept(Array(posts))
            case .error(let error):
                print("\(error.localizedDescription)")
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}
