//
//  CtaReactiveMasterTests.swift
//  CtaReactiveMasterTests
//
//  Created by 小幡 十矛 on 2020/11/21.
//

import XCTest
@testable import CtaReactiveMaster

class CtaReactiveMasterTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let articles = [
            Article(source: Source(name: "ニュース1"), author: "こーへい1", title: "優勝1", description: "abcdefghijklmnopqrstuvwxyz1", url: nil, urlToImage: nil, publishedAt: Date(), content: "12345678901"),
            Article(source: Source(name: "ニュース2"), author: "こーへい2", title: "優勝1", description: "abcdefghijklmnopqrstuvwxyz1", url: nil, urlToImage: nil, publishedAt: Date(), content: "12345678902"),
            Article(source: Source(name: "ニュース3"), author: "こーへい3", title: "優勝3", description: "abcdefghijklmnopqrstuvwxyz1", url: nil, urlToImage: nil, publishedAt: Date(), content: "12345678903")
        ]

        let news = News(status: nil, totalResults: nil, articles: articles)
        let newsRepository = NewsRepositoryMock(apiClient: APIClient(decoder: JSONDecoder()))
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
