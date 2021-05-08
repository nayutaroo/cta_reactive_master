//
//  HomeViewController.swift
//  CtaReactiveMaster
//
//  Created by Takuma Osada on 2020/11/21.
//

import UIKit
import RxCocoa
import RxSwift
import SafariServices

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
    private let viewModel: HomeViewModel
    private let refreshControl = UIRefreshControl()

    init(viewModel: HomeViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        addRxObserver()
        viewModel.$viewDidLoad.accept(())
    }

    private func addRxObserver() {
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: Binder(self) { me, _ in
                me.viewModel.$refresh.accept(())
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

        viewModel.articles
            .bind(to: tableView.rx.items(cellIdentifier: NewsTableViewCell.identifier,
                                         cellType: NewsTableViewCell.self)) { _, article, cell in
                cell.configure(with: article)
            }
            .disposed(by: disposeBag)

        viewModel.isFetching
            .filter { $0 }
            .filter { [weak self] _ in self?.refreshControl.isRefreshing == false }
            .map { _ in }
            .bind(to: activityIndicator.rx.startAnimating)
            .disposed(by: disposeBag)

        viewModel.isFetching
            .filter { !$0 }
            .map { _ in }
            .bind(to: activityIndicator.rx.stopAnimating, refreshControl.rx.endRefreshing)
            .disposed(by: disposeBag)

        viewModel.error
            .bind(to: Binder(self) { me, error in
                me.showRetryAlert(with: error) {
                    me.viewModel.$retryFetch.accept(())
                }
            })
            .disposed(by: disposeBag)
    }

    private func viewSetup() {
        navigationItem.title = "NewsAPI"
        navigationController?.navigationBar.titleTextAttributes
            = [
                NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 24)!,
                NSAttributedString.Key.foregroundColor: UIColor(red: 22/255, green: 61/255, blue: 103/255, alpha: 1.0)
            ]
        navigationController?.navigationBar.backgroundColor = UIColor.brown
    }
}
