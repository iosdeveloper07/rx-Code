//
//  PostsViewController.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var postStorage: PostStorageProtocol = DatabaseService.shared
    private var viewModel: PostsViewModel!
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
        viewModel.fetchInitialData()
    }
    
    func inject(postStorage: PostStorageProtocol) {
        self.postStorage = postStorage
        self.viewModel = PostsViewModel(postStorage: postStorage)
    }

    private func setupUI() {
        title = "Posts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupTableView() {
        let nib = UINib(nibName: PostTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0 
        tableView.tableFooterView = UIView()
    }

    private func setupBindings() {
        viewModel.posts
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { (row, post, cell) in
                cell.configure(with: post)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Post.self)
            .subscribe(onNext: { [weak self] post in
                self?.viewModel.toggleFavorite(postId: post.id)
                if let selectedIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.activityIndicator.isHidden = !isLoading
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)

        viewModel.navigateToLogin
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                 self?.navigateToLoginScreen()
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshData() {
        viewModel.refreshData()
    }

    @objc private func logoutTapped() {
         viewModel.logout()
    }

     private func navigateToLoginScreen() {
         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window else { return }

         let loginStoryboard = UIStoryboard(name: "Main", bundle: nil) 
         guard let loginVC = loginStoryboard.instantiateInitialViewController() else {
             let loginVC = LoginViewController()
             window.rootViewController = loginVC
             window.makeKeyAndVisible()
             UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
             return
         }

         window.rootViewController = loginVC
         window.makeKeyAndVisible()
         UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
     }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
