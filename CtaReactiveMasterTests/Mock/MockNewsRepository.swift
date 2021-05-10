//
//  MockNewsRepository.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/08.
//

import Foundation
@testable import CtaReactiveMaster
import RxSwift

struct MockNewsRepository: NewsRepository {
    let apiClient: APIClient
    let news: News

    func fetchNews() -> Single<News> {
        Single<News>.create(subscribe: { observer in
            observer(.success(news))
            return Disposables.create()
        })
    }
}
