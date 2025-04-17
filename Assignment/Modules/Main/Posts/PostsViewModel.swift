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

    let posts: BehaviorRelay<[Post]> = BehaviorRelay(value: [])
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let error: PublishSubject<String> = PublishSubject()
    let navigateToLogin = PublishSubject<Void>()
    
    private let networkService: NetworkService
    private let postStorage: PostStorageProtocol
    private let disposeBag = DisposeBag()
    private var notificationToken: NotificationToken?

    init(networkService: NetworkService = .shared, postStorage: PostStorageProtocol = DatabaseService.shared) {
        self.networkService = networkService
        self.postStorage = postStorage
        observeDatabaseChanges()
    }

    func fetchInitialData() {
        fetchPostsFromNetwork()
    }

    func refreshData() {
        fetchPostsFromNetwork()
    }

    func toggleFavorite(postId: Int) {
        postStorage.toggleFavoriteStatus(postId: postId)
    }

    func logout() {
        UserDefaultsManager.shared.isLoggedIn = false
        navigateToLogin.onNext(())
    }
    
    private func observeDatabaseChanges() {
        postStorage.getAllPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] results in
                self?.notificationToken?.invalidate()
                self?.notificationToken = results.observe { [weak self] changes in
                    guard let self = self else { return }
                    switch changes {
                    case .initial(let postsResult),
                         .update(let postsResult, _, _, _):
                        self.posts.accept(Array(postsResult))
                    case .error:
                        self.error.onNext("Failed to load posts from database.")
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func fetchPostsFromNetwork() {
        guard !isLoading.value else { return }
        isLoading.accept(true)

        networkService.fetchPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] postsDecodable in
                    self?.postStorage.saveOrUpdatePosts(postsDecodable)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.error.onNext("Failed to fetch posts. Showing cached data.")
                    self?.isLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }

    deinit {
        notificationToken?.invalidate()
    }
}
