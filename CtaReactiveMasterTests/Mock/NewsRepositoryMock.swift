//
//  NewsRepositoryMock.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/08.
//

@testable import CtaReactiveMaster
import Foundation
import RxSwift

struct NewsRepositoryMock: NewsRepository {

    let apiClient: APIClient

    init(apiClient: APIClient = .init(decoder: .iso8601)) {
        self.apiClient = apiClient
    }

    func fetchNews() -> Single<News> {
        createMockNews()
    }

    func searchNews(_ keyword: String) -> Single<News> {
        createMockNews()
    }

    private func createMockNews() -> Single<News> {
        Single<News>.create(subscribe: { observer in
            observer(.success(.mock))
            return Disposables.create()
        })
    }
}
