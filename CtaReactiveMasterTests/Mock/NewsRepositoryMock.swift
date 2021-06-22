//
//  NewsRepositoryMock.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/08.
//

@testable import CtaReactiveMaster
import Foundation
import RxRelay
import RxSwift

struct NewsRepositoryMock: NewsRepository {

    let apiClient: APIClient
    var searchNewsParameter: Observable<String> {
        _searchNewsParameter.asObservable()
    }
    private let _searchNewsParameter = PublishRelay<String>()

    init(apiClient: APIClient = .init(decoder: .iso8601)) {
        self.apiClient = apiClient
    }

    func fetchNews() -> Single<News> {
        createMockNews()
    }

    func searchNews(_ keyword: String) -> Single<News> {
        _searchNewsParameter.accept(keyword)
        return createMockNews()
    }

    private func createMockNews() -> Single<News> {
        Single<News>.create(subscribe: { observer in
            observer(.success(.mock))
            return Disposables.create()
        })
    }
}
