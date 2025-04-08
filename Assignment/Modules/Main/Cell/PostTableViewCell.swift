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
        favoriteIndicatorImageView?.tintColor = .systemYellow
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.text = nil
        favoriteIndicatorImageView.isHidden = true
    }

    func configure(with post: Post) {
        titleLabel.text = post.title
        bodyLabel.text = post.body
        favoriteIndicatorImageView.isHidden = !post.isFavorite
        accessoryType = .none
    }
}
