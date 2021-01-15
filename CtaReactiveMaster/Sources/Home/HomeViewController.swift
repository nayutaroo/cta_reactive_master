//
//  HomeViewController.swift
//  CtaReactiveMaster
//
//  Created by Takuma Osada on 2020/11/21.
//

import UIKit
import Alamofire
import SafariServices

final class HomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: NewsTableViewCell.identifier)
            tableView.refreshControl = UIRefreshControl()
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private var articles:[Article] = []
    
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
    }
    
    private func fetchNewsAPI(){
        
        AF.request("http://newsapi.org/v2/everything?q=bitcoin&from=2020-12-14&sortBy=publishedAt&apiKey=67945148525042b9b63954def7a50c38").response { [weak self] response in
        
            guard let self = self else {return}

            switch response.result {
                case .success(let data):
                    guard let data = data else { return }
                    
                    do{
                        //APIのデータに従った構造体を書く → 取得するJSONのデータに合わせた構造体jsonDataを定義
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.dateDecodingStrategy = .iso8601
                        let news = try jsonDecoder.decode(News.self, from: data)
                        self.articles = news.articles
                    }
                    catch let error{
                        print(error)
                        self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
                        self.AfterFetch()
                        return
                    }
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    //selfをあらかじめアンラップすることによりfetchnewsAPI → ?? () -> ()を使用することがない状態に
                    self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
                    print(error)
            }
            self.AfterFetch()
        }
    }
    
    private func afterFetch(){
        self.activityIndicator.stopAnimating()
        let isRefreshing = self.tableView.refreshControl?.isRefreshing ?? false
        if isRefreshing {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func showRetryAlert(with error: Error, retryhandler: @escaping () -> ()) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            retryhandler()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func refresh(sender: UIRefreshControl){
        fetchNewsAPI()
    }
}

extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string:articles[indexPath.row].url ?? "") else { return }
        present(SFSafariViewController(url: url), animated: true)
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
