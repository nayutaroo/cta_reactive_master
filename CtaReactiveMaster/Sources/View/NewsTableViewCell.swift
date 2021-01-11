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
    
    func setImage(with url: URL) {
        iconImageView.kf.setImage(with: url)
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        let publishedAt = article.publishedAt ?? ""
        let date = DateUtils.dateFromString(string: publishedAt, format: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'")
        
        //guardはスコープの問題でエラーに
        if let date = date {
            let formattedDate = DateUtils.stringFromDate(date: date, format: "yyyy年 MM月dd日  HH時mm分")
            publishedAtLabel.text = formattedDate
            guard let url = URL(string: article.urlToImage ?? "")
            else{
                return
            }
            setImage(with: url)
        }
        else{
            return
        }
    }
}
