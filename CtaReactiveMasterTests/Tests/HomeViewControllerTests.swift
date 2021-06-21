//
//  HomeViewControllerTests.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/06/17.
//

@testable import CtaReactiveMaster
import RxSwift
import RxCocoa
import XCTest

class HomeViewControllerTests: XCTestCase {

    private struct Dependency {

        let homeViewController: HomeViewController
        let actionCreator: NewsRepositoryActionCreator
        let repository: NewsRepositoryMock

        init() {
            repository = NewsRepositoryMock()
            let flux: Flux = .mock(newsRepositoryMock: repository)
            let homeViewModel = HomeViewModel(flux: flux)
            let sideMenuViewModel = SideMenuViewModel(flux: flux)
            let sideMenuViewController = SideMenuViewController(viewModel: sideMenuViewModel)
            self.homeViewController = HomeViewController(
                viewModel: homeViewModel,
                sideMenuViewController: sideMenuViewController
            )
            sideMenuViewController.loadViewIfNeeded()
            homeViewController.loadViewIfNeeded()
            self.actionCreator = flux.newsRepositoryActionCreator
        }
    }

    private var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testViewDidLoadAndReloadData() {
        let tableView: UITableView = dependency.homeViewController.tableView
        let news: News = .mock
        let testArticles: [Article] = news.articles
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), testArticles.count)
        dependency.actionCreator.fetchNews.accept(())
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), testArticles.count)
    }

    func testTappedSearchButton() {
        let query = "keyword"
        let expect = expectation(description: "wating search")

        let disposable = dependency.repository.searchNewsParameter
            .subscribe(onNext: { _query in
                XCTAssertEqual(_query, query)
                expect.fulfill()
            })

        let sideMenuVC = dependency.homeViewController.sideMenuViewController
        let textField = sideMenuVC?.textField
        textField?.text = query
        textField?.sendActions(for: .valueChanged)
        sideMenuVC?.button.sendActions(for: .touchUpInside)

        wait(for: [expect], timeout: 0.1)
        disposable.dispose()
    }
}
