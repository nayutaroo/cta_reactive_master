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
}
struct NewsRepositoryImpl: NewsRepository {
    let apiClient = APIClient(decoder: .iso8601)
    func fetchNews() -> Single<News> {
        let request = NewsAPIRequest(endpoint: .topHeadlines(.us, .technology))
        return apiClient.request(request)
    }
}
