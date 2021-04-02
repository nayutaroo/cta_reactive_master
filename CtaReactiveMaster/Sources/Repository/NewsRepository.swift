//
//  NewsRepository.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/16.
//

import Foundation
import RxSwift

protocol Repository {
    associatedtype Response
    var apiClient: APIClient { get }
    func fetch() -> Single<News>
}

struct NewsRepository: Repository {
    typealias Response = News
    
    let apiClient = APIClient(decoder: .iso8601)
    
    func fetch() -> Single<News> {
        let request = NewsAPIRequest(endpoint: .topHeadlines(.us, .technology))
        return apiClient.request(request)
    }
}
