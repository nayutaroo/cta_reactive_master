//
//  NewsTableViewCell.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/06.
//

import UIKit
import Kingfisher

final class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var publishedAtLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
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
    
        guard let date = article.publishedAt else { return }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月dd日  HH時mm分"
        publishedAtLabel.text = formatter.string(from: date)
        guard let url = URL(string: article.urlToImage ?? "") else{ return }
        setImage(with: url)
    }
}
