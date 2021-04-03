//
//  NewsRepositoryDispatcher.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/02.
//

import RxSwift
import RxRelay

final class NewsRepositoryDispatcher {
    static let shared = NewsRepositoryDispatcher()

    let articles = PublishRelay<[Article]>()
    let isFetching = PublishRelay<Bool>()
    let error = PublishRelay<Error>()

    private init() {}
}
