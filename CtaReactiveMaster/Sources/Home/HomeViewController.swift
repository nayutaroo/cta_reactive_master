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
    private let repository : NewsRepository
    
    // Dependency Injection ( オブジェクトの注入 ）
    init(repository: NewsRepository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        //この時点ではresultの内容はわかっていないが奥深くにあるrequestメソッドでこのクロージャを使う際にそのrequestメソッドで引数を設定できる。
        // 疑問: なぜここでクロージャを設定する必要がある？？
        // ⇨ 別のリクエストをフェッチする際にクロージャの内容を変更できるようにするため
        repository.fetch { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(let model):
                self.articles = model.articles
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            case .failure(let error):
                switch error{
                case let .decode(error):
                    //デコードエラー
                    print("Decode Error")
                    self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
                case let .unknown(error):
                    //通信が繋がっていない際のエラー
                    print("Unknown Error")
                    self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
                case .noResponse:
                    //レスポンスがない場合のエラー
                    print("No Response Error")
                }
            }
            self.afterFetch()
        }
    }
    
    private func afterFetch() {
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        let isRefreshing = tableView.refreshControl?.isRefreshing ?? false
        if isRefreshing {
            tableView.refreshControl?.endRefreshing()
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
        if let urlString = articles[indexPath.row].url, let url = URL(string: urlString) {
            present(SFSafariViewController(url: url), animated: true)
        }
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
