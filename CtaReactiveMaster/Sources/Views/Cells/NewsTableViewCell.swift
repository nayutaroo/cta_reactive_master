//
//  NewsTableViewCell.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/06.
//

import Kingfisher
import RxSwift
import UIKit

final class NewsTableViewCell: UITableViewCell {

    @IBOutlet private weak var publishedAtLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var favoriteIconImageView: UIImageView!

    static var identifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
    }

    var disposeBag = DisposeBag()
    var isFavorited: Bool = false {
        didSet {
            favoriteIconImageView.image = isFavorited ? #imageLiteral(resourceName: "red_heart") : nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
    }

    private func setImage(with url: URL) {
        iconImageView.kf.setImage(with: url)
    }

    func configure(with article: Article) {
        titleLabel.text = article.title

        if let publishedAt = article.publishedAt {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy年 MM月dd日  HH時mm分"
            publishedAtLabel.text = formatter.string(from: publishedAt)
        }
        if let urlString = article.urlToImage, let url = URL(string: urlString) {
            setImage(with: url)
        }
    }
}
