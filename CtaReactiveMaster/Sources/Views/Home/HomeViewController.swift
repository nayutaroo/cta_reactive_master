//
//  HomeViewController.swift
//  CtaReactiveMaster
//
//  Created by Takuma Osada on 2020/11/21.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
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

    private var menuButton: UIBarButtonItem!
    private var sideMenuViewController: SideMenuViewController!

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
        setupView()
        addRxObserver()
        viewModel.$viewDidLoad.accept(())
    }

    private func addRxObserver() {

        menuButton.rx.tap
            .bind(to: Binder(self) { me, _ in
                me.viewModel.$tapMenuButton.accept(())
            })
            .disposed(by: disposeBag)

        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: Binder(self) { me, _ in
                me.viewModel.$refresh.accept(())
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Article.self)
            .bind(to: Binder(self) { me, article in
                guard let urlString = article.url else { return }
                me.viewModel.$selectArticle.accept(URL(string: urlString))
            })
            .disposed(by: disposeBag)

        viewModel.$transitionState
            .bind(to: Binder(self) { me, state in
                switch state {
                case .detail(let url):
                    guard let url = url else { return }
                    me.present(SFSafariViewController(url: url), animated: true)
                case .sideMenu:
                    // TODO: サイドメニューの表示
                    me.showSideMenu(animated: true)
                default:
                    break
                }
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

    private func setupView() {

        menuButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        menuButton.tintColor = .init(red: 22/255, green: 61/255, blue: 103/255, alpha: 1.0)

        sideMenuViewController = .init()
        sideMenuViewController.delegate = self
        sideMenuViewController.startPanGestureRecognizing()

        navigationItem.leftBarButtonItem = menuButton
        navigationItem.title = "NewsAPI"
        navigationController?.navigationBar.titleTextAttributes
            = [
                NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 24)!,
                NSAttributedString.Key.foregroundColor: UIColor(red: 22/255, green: 61/255, blue: 103/255, alpha: 1.0)
            ]
        navigationController?.navigationBar.backgroundColor = UIColor.brown
    }

    private func showSideMenu(contentAvailability: Bool = true, animated: Bool) {
        print("サイドメニューの表示")

        guard let navigationController = self.navigationController else { return }
        navigationController.addChild(sideMenuViewController)
        sideMenuViewController.view.autoresizingMask = .flexibleHeight
        sideMenuViewController.view.frame = view.bounds
        navigationController.view.addSubview(sideMenuViewController.view)
        sideMenuViewController.didMove(toParent: self)

        if contentAvailability {
            sideMenuViewController.showContentView(animated: true)
        }
    }

    private func hideSideMenu(animated: Bool) {
        sideMenuViewController.hideContentView(animated: animated) { _ in
            self.sideMenuViewController.willMove(toParent: nil)
            self.sideMenuViewController.removeFromParent()
            self.sideMenuViewController.view.removeFromSuperview()
        }
    }
}

extension HomeViewController: SideMenuViewControllerDelegate {
    func parentViewControllerForSideMenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController {
        return self
    }

    func shouldPresentForSideMenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool {
        return true
    }

    func sideMenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool) {
        showSideMenu(contentAvailability: contentAvailability, animated: animated)
    }

    func sideMenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool) {
        hideSideMenu(animated: animated)
    }

    func sideMenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath) {
        hideSideMenu(animated: true)
    }
}
