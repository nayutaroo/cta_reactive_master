//
//  HomeViewController.swift
//  CtaReactiveMaster
//
//  Created by Takuma Osada on 2020/11/21.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: NewsTableViewCell.identifier)
            tableView.refreshControl = UIRefreshControl()
        }
    }
    
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private var articles: [Article] = []
    private let disposeBag = DisposeBag()
    private let viewModel: HomeViewModelProtocol
    
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
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
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .subscribe(
                onNext: { [weak self] in
                    self?.fetchNewsAPI()
                })
            .disposed(by: disposeBag)
        activityIndicator.startAnimating()
        fetchNewsAPI()
    }
    
    private func fetchNewsAPI() {
        
//        repository.fetch()
//            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
//            .observe(on: MainScheduler.instance)
//            .subscribe(
//                onSuccess: { model in
//                    self.articles = model.articles
//                    self.tableView.reloadData()
//                    self.afterFetch()
//                },
//                onFailure: { error in
//                    if let error = error as? NewsAPIError {
//                        switch error{
//                        case let .decode(error):
//                            self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
//                        case let .unknown(error):
//                            self.showRetryAlert(with: error, retryhandler: self.fetchNewsAPI)
//                        case .noResponse:
//                            //レスポンスがない場合のエラー
//                            print("No Response Error")
//                        }
//                    }
//                })
//            .disposed(by: disposeBag)
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
}

extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = articles[indexPath.row].url, let url = URL(string: urlString) else {
            return
        }
        present(SFSafariViewController(url: url), animated: true)
    }
}

extension HomeViewController : UITableViewDataSource {
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
