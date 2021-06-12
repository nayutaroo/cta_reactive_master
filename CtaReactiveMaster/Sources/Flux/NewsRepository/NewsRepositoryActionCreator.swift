//
//  NewsRepositoryActionCreator.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/02.
//

import Foundation
import RxRelay
import RxSwift

final class NewsRepositoryActionCreator {
    static let shared = NewsRepositoryActionCreator()

    private let repository: NewsRepository
    private let dispatcher: NewsRepositoryDispatcher
    private let disposeBag = DisposeBag()
    let fetchNews = PublishRelay<Void>()
    let searchNews = PublishRelay<String>()

    init(dispatcher: NewsRepositoryDispatcher = .shared,
         repository: NewsRepository = NewsRepositoryImpl()) {
        self.dispatcher = dispatcher
        self.repository = repository

        let fetchedEvent = fetchNews
            .do(onNext: {
                print("fetchNews")
            })
            .flatMap {
                repository.fetchNews().asObservable().materialize()
            }
            .share()

        fetchedEvent.flatMap { $0.element.map(Observable.just) ?? .empty() }
            .map(\.articles)
            .bind(to: dispatcher.articles)
            .disposed(by: disposeBag)

        fetchedEvent.flatMap { $0.error.map(Observable.just) ?? .empty() }
            .bind(to: dispatcher.error)
            .disposed(by: disposeBag)

        let searchedEvent = searchNews
            .do(onNext: { _ in
                print("searchNews")
            })
            .flatMap { keyword in
                repository.searchNews(keyword).asObservable().materialize()
            }
            .share()

        searchedEvent.flatMap { $0.element.map(Observable.just) ?? .empty() }
            .map(\.articles)
            .bind(to: dispatcher.articles)
            .disposed(by: disposeBag)

        searchedEvent.flatMap { $0.error.map(Observable.just) ?? .empty() }
            .bind(to: dispatcher.error)
            .disposed(by: disposeBag)

        Observable.merge(fetchNews.map { _ in true },
                         searchNews.map { _ in true },
                         searchedEvent.map { _ in false },
                         fetchedEvent.map { _ in false })
            .bind(to: dispatcher.isFetching)
            .disposed(by: disposeBag)
    }
}
