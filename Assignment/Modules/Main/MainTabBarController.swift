//
//  MainTabBarController.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let postsStoryboard = UIStoryboard(name: "Posts", bundle: nil)
        let postsVC = postsStoryboard.instantiateViewController(withIdentifier: "PostsViewController") as! PostsViewController
        postsVC.inject(postStorage: DatabaseService.shared)
        let postsNavController = postsStoryboard.instantiateInitialViewController() ?? UINavigationController(rootViewController: postsVC)
        postsNavController.tabBarItem = UITabBarItem(title: "Posts", image: UIImage(systemName: "list.bullet"), tag: 0)

        let favoritesStoryboard = UIStoryboard(name: "Favorites", bundle: nil)
        let favoritesVC = favoritesStoryboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        favoritesVC.inject(postStorage: DatabaseService.shared)
        let favoritesNavController = favoritesStoryboard.instantiateInitialViewController() ?? UINavigationController(rootViewController: favoritesVC)
        favoritesNavController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 1)


        viewControllers = [postsNavController, favoritesNavController]
        tabBar.tintColor = .systemBlue
    }
}
