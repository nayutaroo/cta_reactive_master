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

            self.actionCreator = flux.newsRepositoryActionCreator
            self.store = flux.newsRepositoryStore
            self.dispatcher = flux.newsRepositoryDispatcher

            self.viewModel = HomeViewModel()
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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
