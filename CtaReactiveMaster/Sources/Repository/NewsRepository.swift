//
//  NewsRepository.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/16.
//

import Foundation
import RxSwift

protocol NewsRepository {
    var apiClient: APIClient { get }
    func fetchNews() -> Single<News>
    func searchNews(_ keyword: String) -> Single<News>
}
struct NewsRepositoryImpl: NewsRepository {
    let apiClient: APIClient

    init(apiClient: APIClient = APIClient(decoder: .iso8601)) {
        self.apiClient = apiClient
    }

    func fetchNews() -> Single<News> {
        let request = NewsAPIRequest(endpoint: .topHeadlines(.jp, .general))
        return apiClient.request(request)
    }

    func searchNews(_ keyword: String) -> Single<News> {
        let request = NewsAPIRequest(endpoint: .everything(keyword))
        return apiClient.request(request)
    }
}
