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
            tableView.register(NewsTableViewCell.nib, forCellReuseIdentifier: NewsTableViewCell.identifier)
            tableView.refreshControl = refreshControl
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel: HomeViewModelProtocol
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        
        viewModel.input.viewDidLoad()
        
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: Binder(self) { me, _ in
                me.viewModel.input.refresh()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Article.self)
            .bind(to: Binder(self) { me, article in
                guard let urlString = article.url, let url = URL(string: urlString) else {
                    return
                }
                me.present(SFSafariViewController(url: url), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.articles.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: NewsTableViewCell.identifier, cellType: NewsTableViewCell.self)) { _, article, cell in
                cell.configure(with: article)
            }
            .disposed(by: disposeBag)
        
//        viewModel.output.loadingStatus
//            .flatMap { status -> Observable<Void> in
//                switch status {
//                case .initial, .loadSuccess:
//                    return .just(())
//                case .isLoading, .loadFailed:
//                    return .empty()
//                }
//            }
//            .bind(to: activityIndicator.rx.stopAnimating, refreshControl.rx.endRefreshing)
//            .disposed(by: disposeBag)
        
        viewModel.output.loadingStatus
            .subscribe(Binder(self) { me, status in
                switch status {
                case .initial, .loadSuccess:
                    Observable.just(())
                        .bind(to: me.activityIndicator.rx.stopAnimating, me.refreshControl.rx.endRefreshing)
                        .disposed(by: me.disposeBag)
                case .isLoading:
                    Observable.just(())
                        .bind(to: me.activityIndicator.rx.startAnimating)
                        .disposed(by: me.disposeBag)
                case .loadFailed(let error):
                    Observable.just(error)
                        .bind(to: Binder(self) { me, error in
                            me.showRetryAlert(with: error, retryhandler: me.viewModel.input.retryFetch)
                        })
                        .disposed(by: me.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
//        viewModel.output.loadingStatus
//            .flatMap { status -> Observable<Void> in
//                switch status {
//                case .isLoading:
//                    return .just(())
//                case .initial, .loadSuccess, .loadFailed:
//                    return .empty()
//                }
//            }
//            .bind(to: activityIndicator.rx.startAnimating)
//            .disposed(by: disposeBag)
//
//        viewModel.output.loadingStatus
//            .flatMap { status -> Observable<Error> in
//                switch status {
//                case .loadFailed(let error):
//                    return .just(error)
//                case .initial, .isLoading, .loadSuccess:
//                    return .empty()
//                }
//            }
//            .subscribe(Binder(self) { me, error in
//                me.showRetryAlert(with: error, retryhandler: me.viewModel.input.retryFetch)
//            })
//            .disposed(by: disposeBag)
    }
    
    private func viewSetup() {
        navigationItem.title = "NewsAPI"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 24)!]
        navigationController?.navigationBar.backgroundColor = UIColor.brown
    }
}
