//
//  HomeViewController.swift
//  CtaReactiveMaster
//
//  Created by Takuma Osada on 2020/11/21.
//

import Foundation
import UIKit
import Alamofire

final class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: NewsTableViewCell.identifier)
            tableView.refreshControl = UIRefreshControl()
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var articles:[Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NewsAPI"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 24)!]
        navigationController?.navigationBar.backgroundColor = UIColor.brown
        
        activityIndicator.hidesWhenStopped = true
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
       
        activityIndicator.startAnimating()
        fetchNewsAPI()
        activityIndicator.stopAnimating()
    }
    
    private func fetchNewsAPI(){
        
        AF.request("http://newsapi.org/v2/everything?q=bitcoin&from=2020-12-08&sortBy=publishedAt&apiKey=67945148525042b9b63954def7a50c38").response { [weak self] response in

            switch response.result {
                case .success(let data):
                    guard let unwrappedData = data
                    else{
                        return
                    }
                    
                    do{
                        //APIのデータに従った構造体を書く → 取得するJSONのデータに合わせた構造体jsonDataを定義
                        let jsonData = try JSONDecoder().decode(JsonData.self, from: unwrappedData)
                        self?.articles = jsonData.articles
                    }
                    catch let error{
                        print(error)
                        return
                    }
                    self?.tableView.reloadData()
                    break
                    
                case .failure(let error):
                    UIAlertController.showRetryAlert(to: self, with: error, retryhandler: self?.fetchNewsAPI ?? {()-> Void in return})
                    print(error)
            }
            
            let isRefreshing = self?.tableView.refreshControl?.isRefreshing ?? false
            if isRefreshing{
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func refresh(sender: UIRefreshControl){
        fetchNewsAPI()
    }
}

extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = articles[indexPath.row].url
        else {
            return
        }
        navigationController?.pushViewController(WebDetailViewController(url: url), animated: true)
    }
}

extension HomeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier) as! NewsTableViewCell
        let article = articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}
