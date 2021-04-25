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

//    let articles: Property<[Article]>
//    private let _articles = BehaviorRelay<[Article]>(value: [])

    @BehaviorRelayOutput(value: []) private(set) var articles: [Article]
    @BehaviorRelayOutput(value: false) private(set) var isFetching: Bool

//    let isFetching: Property<Bool>
//    private let _isFetching = BehaviorRelay<Bool>(value: false)

    //状態として保持しない場合はObservableのみで良い
    let error: Observable<Error>

    private init(dispatcher: NewsRepositoryDispatcher = .shared) {
        self.dispatcher = dispatcher
        error = dispatcher.error.asObservable()

//        isFetching = Property(_isFetching)

        dispatcher.articles
            .bind(to: _articles)
            .disposed(by: disposeBag)

        dispatcher.isFetching
            .bind(to: _isFetching)
            .disposed(by: disposeBag)
    }
}
