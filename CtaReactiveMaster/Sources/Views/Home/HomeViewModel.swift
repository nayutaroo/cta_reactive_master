//
//  HomeViewModel.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/05.
//

import Foundation
import RxCocoa
import RxSwift

final class HomeViewModel {

    @PublishRelayInput var viewDidLoad: Observable<Void>
    @PublishRelayInput var retryFetch: Observable<Void>
    @PublishRelayInput var refresh: Observable<Void>

    private let disposeBag = DisposeBag()

    let articles: Observable<[Article]>
    let isFetching: Observable<Bool>
    let error: Observable<Error>

    init(flux: Flux = .shared) {

        let newsActionCreator = flux.newsRepositoryActionCreator
        let newsStore = flux.newsRepositoryStore

        articles = newsStore.$articles
        isFetching = newsStore.$isFetching

        error = newsStore.error
            .flatMap { error -> Observable<Error> in
                guard let error = error as? APIError else { return .empty() }
                switch error {
                case let .decode(error), let .unknown(error):
                    return .just(error)
                case .noResponse:
                    let error = NSError(domain: "サーバからの応答がありません。", code: -1, userInfo: nil)
                    return .just(error)
                }
            }
            .share()

        Observable.merge(viewDidLoad, refresh, retryFetch)
            .subscribe(onNext: {
                newsActionCreator.fetchNews.accept(())
            })
            .disposed(by: disposeBag)
    }
}
