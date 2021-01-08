//
//  NewsTableViewCell.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/06.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var publishedAtLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
    }
    
    func setImage(with url: URL) {
        iconImageView.kf.setImage(with: url)
    }
    
    func configure(with article: Article) {
        let article = article
        titleLabel.text = article.title ?? ""
        let publishedAt = article.publishedAt ?? ""
        let date = DateUtils.dateFromString(string: publishedAt, format: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'")
        guard let unwrappedDate = date else{
            return
        }
        let formattedDate = DateUtils.stringFromDate(date: unwrappedDate, format: "yyyy年MM月dd日 HH時mm分")
        publishedAtLabel.text = formattedDate
        guard let url = URL(string: article.urlToImage ?? "")
        else{
            return
        }
        setImage(with: url)
    }
}
