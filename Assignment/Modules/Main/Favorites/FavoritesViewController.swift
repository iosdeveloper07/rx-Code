//
//  FavoritesViewController.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    private let viewModel = FavoritesViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
    }

    private func setupUI() {
        title = "Favorites"
        emptyStateLabel?.text = "No favorite posts"
        emptyStateLabel?.isHidden = true
    }

    private func setupTableView() {
        let nib = UINib(nibName: PostTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.rowHeight = 100.0 
        tableView.tableFooterView = UIView()

        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                 let postToDelete = self.viewModel.favoritePosts.value[indexPath.row]
                 self.viewModel.unfavoritePost(postId: postToDelete.id)
                 self.showFavouritePostDeletedAlert()
            })
            .disposed(by: disposeBag)
    }

    private func setupBindings() {
        viewModel.favoritePosts
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { (row, post, cell) in
                cell.configure(with: post)
            }
            .disposed(by: disposeBag)
        
        viewModel.favoritePosts
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.favoritePosts
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateLabel.rx.isHidden)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
             .subscribe(onNext: { [weak self] indexPath in
                 self?.tableView.deselectRow(at: indexPath, animated: true)
             })
             .disposed(by: disposeBag)
    }
    
    private func showFavouritePostDeletedAlert() {
        let alert = UIAlertController(title: "Success", message: "Post Deleted Suucessfully !!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
