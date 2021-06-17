//
//  NewsRepositoryActionCreatorTests.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/27.
//

@testable import CtaReactiveMaster
import XCTest

class NewsRepositoryActionCreatorTests: XCTestCase {

    private struct Dependency {
        let actionCreator: NewsRepositoryActionCreator
        let dispatcher: NewsRepositoryDispatcher

        init() {
            let flux: Flux = .mock()

            self.actionCreator = flux.newsRepositoryActionCreator
            self.dispatcher = flux.newsRepositoryDispatcher
        }
    }
    private var dependency: Dependency!

    override func setUp() {
        self.dependency = Dependency()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFetchNews() throws {
        let news: News = .mock
        let testArticles: [Article] = news.articles
        var fetchedArticles: [Article] = []

        let expect = expectation(description: "waiting actionCreator.fetchNews")
        let disposable = dependency.dispatcher.articles
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
