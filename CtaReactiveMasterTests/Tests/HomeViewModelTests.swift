//
//  HomeViewModelTests.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/10.
//

@testable import CtaReactiveMaster
import XCTest

class HomeViewModelTests: XCTestCase {

    private struct Dependency {
        let actionCreator: NewsRepositoryActionCreator
        let store: NewsRepositoryStore
        let dispatcher: NewsRepositoryDispatcher

        let viewModel: HomeViewModel

        init() {
            let flux: Flux = .mock()

            self.viewModel = HomeViewModel(flux: flux)
            self.actionCreator = flux.newsRepositoryActionCreator
            self.store = flux.newsRepositoryStore
            self.dispatcher = flux.newsRepositoryDispatcher
        }
    }

    private var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testFetchNews() {
        let news: News = .mock
        let testArticles: [Article] = news.articles
        var fetchedArticles: [Article] = []

        let expect = expectation(description: "waiting viewModel.fetchNews")
        let disposable = dependency.viewModel.articles
            .skip(1)
            .subscribe(onNext: { articles in
                fetchedArticles = articles
                expect.fulfill()
            })

        dependency.actionCreator.fetchNews.accept(())
        wait(for: [expect], timeout: 0.1)
        disposable.dispose()

        XCTAssertEqual(fetchedArticles.count, testArticles.count)
        XCTAssertNotNil(fetchedArticles.first)
        XCTAssertEqual(fetchedArticles.first?.author, testArticles.first?.author)
        XCTAssertEqual(fetchedArticles.first?.content, testArticles.first?.content)
        XCTAssertEqual(fetchedArticles.first?.description, testArticles.first?.description)
        XCTAssertEqual(fetchedArticles.first?.title, testArticles.first?.title)
        XCTAssertEqual(fetchedArticles.first?.url, testArticles.first?.url)
        XCTAssertEqual(fetchedArticles.first?.urlToImage, testArticles.first?.urlToImage)
        XCTAssertEqual(fetchedArticles.first?.publishedAt, testArticles.first?.publishedAt)
    }
}
