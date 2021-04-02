//
//  NewsRepositoryStore.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/02.
//

import Foundation
import RxSwift
import RxCocoa

final class NewsRepositoryStore {

    static let shared = NewsRepositoryStore()
    private let dispatcher: NewsRepositoryDispatcher

    private let disposeBag = DisposeBag()

    let articles: Property<[Article]>
    private let _articles = BehaviorRelay<[Article]>(value: [])

    let loadingStatus: Property<LoadingStatus>
    private let _loadingStatus = BehaviorRelay<LoadingStatus>(value: .initial)

    //状態として保持しない場合はObservableのみで良い
    let error: Observable<Error>

    private init(dispatcher: NewsRepositoryDispatcher = .shared) {
        self.dispatcher = dispatcher
        error = dispatcher.error.asObservable()

        articles = Property(_articles)
        loadingStatus = Property(_loadingStatus)

        dispatcher.articles
            .bind(to: _articles)
            .disposed(by: disposeBag)

        dispatcher.loadingStatus
            .bind(to: _loadingStatus)
            .disposed(by: disposeBag)
    }
}
