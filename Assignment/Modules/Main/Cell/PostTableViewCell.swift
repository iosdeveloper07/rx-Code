//
//  PostTableViewCell.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    static let identifier = "PostTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var favoriteIndicatorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.text = nil
    }

    func configure(with post: Post, isFavourite: Bool = false) {
        titleLabel.text = post.title
        bodyLabel.text = post.body
        if isFavourite {
            favoriteIndicatorImageView.isHidden = true
        } else {
            favoriteIndicatorImageView.isHidden = false
            let imageName = post.isFavorite ? "heart" : "unselected"
            favoriteIndicatorImageView.image = UIImage(named: imageName)
        }
        accessoryType = .none
    }
}
