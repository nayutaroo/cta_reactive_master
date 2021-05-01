//
//  NewsRepositoryActionCreator.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/02.
//

import Foundation
import RxSwift
import RxRelay

final class NewsRepositoryActionCreator {
    static let shared = NewsRepositoryActionCreator()

    private let repository: NewsRepository
    private let dispatcher: NewsRepositoryDispatcher

    private let disposeBag = DisposeBag()
    private let fetchArticles = PublishRelay<Void>()

    private init(dispatcher: NewsRepositoryDispatcher = .shared,
                 repository: NewsRepository = .init()) {
        self.dispatcher = dispatcher
        self.repository = repository

        let fetchedEvent = fetchArticles
            .flatMap {
                repository.fetch().asObservable().materialize()
            }
            .share()

        fetchedEvent.flatMap { $0.element.map(Observable.just) ?? .empty() }
            .map(\.articles)
            .bind(to: dispatcher.articles)
            .disposed(by: disposeBag)

        fetchedEvent.flatMap { $0.error.map(Observable.just) ?? .empty() }
            .bind(to: dispatcher.error)
            .disposed(by: disposeBag)

        Observable.merge(fetchArticles.map { _ in true },
                         fetchedEvent.map { _ in false })
            .bind(to: dispatcher.isFetching)
            .disposed(by: disposeBag)
    }

    func fetch() {
        fetchArticles.accept(())
    }
}
