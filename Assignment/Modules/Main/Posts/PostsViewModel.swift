//
//  PostsViewModel.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class PostsViewModel {

    // MARK: - Outputs (to View)
    let posts: BehaviorRelay<[Post]> = BehaviorRelay(value: [])
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let error: PublishSubject<String> = PublishSubject() // For displaying errors
    let navigateToLogin = PublishSubject<Void>() // Trigger logout navigation

    // MARK: - Private Properties
    private let networkService: NetworkService
    private let databaseService: DatabaseService
    private let disposeBag = DisposeBag()
    private var notificationToken: NotificationToken? // For Realm updates

    // MARK: - Initialization
    init(networkService: NetworkService = .shared, databaseService: DatabaseService = .shared) {
        self.networkService = networkService
        self.databaseService = databaseService
        observeDatabaseChanges()
        // fetchInitialData() // Fetch immediately on init
    }

    // MARK: - Public Methods

    func fetchInitialData() {
        // 1. Get initial data from DB (will be observed by notification token)
        // The observer will push the initial data to the 'posts' relay.
         print("Initial data will load via Realm observer.")

        // 2. Fetch from network
        fetchPostsFromNetwork()
    }

    func refreshData() {
        fetchPostsFromNetwork()
    }

    func toggleFavorite(postId: Int) {
        databaseService.toggleFavoriteStatus(postId: postId)
    }

    func logout() {
        UserDefaultsManager.shared.isLoggedIn = false
        navigateToLogin.onNext(())
    }

    private func observeDatabaseChanges() {
        let results = databaseService.realm?.objects(Post.self).sorted(byKeyPath: "id", ascending: true) ?? nil
        guard let allPostsResults = results else { return }

        notificationToken = allPostsResults.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial(let postsResult):
                print("Realm initial posts loaded: \(postsResult.count)")
                self.posts.accept(Array(postsResult))
            case .update(let postsResult, _, _, _):
                print("Realm posts updated: \(postsResult.count)")
                self.posts.accept(Array(postsResult))
            case .error(let error):
                print("Realm observation error: \(error.localizedDescription)")
                self.error.onNext("Failed to load posts from database.")
            }
        }
    }

    private func fetchPostsFromNetwork() {
        guard !isLoading.value else { return } // Prevent multiple simultaneous fetches
        isLoading.accept(true)

        networkService.fetchPosts()
            .observe(on: MainScheduler.instance) // Switch to main thread for DB write
            .subscribe(
                onNext: { [weak self] postsDecodable in
                    print("Fetched \(postsDecodable.count) posts from network.")
                    self?.databaseService.saveOrUpdatePosts(postsDecodable)
                    // DB update triggers Realm notification, which updates the 'posts' relay
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    print("Network fetch failed: \(error.localizedDescription)")
                    // Optionally check specific error types (e.g., no internet)
                    self?.error.onNext("Failed to fetch posts. Showing cached data.")
                    self?.isLoading.accept(false)
                    // Data from DB is likely already displayed thanks to the observer
                }
            )
            .disposed(by: disposeBag)
    }

    // Make sure to invalidate the token when the ViewModel is deallocated
    deinit {
        notificationToken?.invalidate()
        print("PostsViewModel deinit, invalidated Realm token.")
    }
}
