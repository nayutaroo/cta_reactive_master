//
//  HomeViewModel.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/05.
//

import RxSwift
import RxCocoa
import Foundation

protocol HomeViewModelProtocol {
    var input: HomeViewModelInputs { get }
    var output: HomeViewModelOutputs { get }
}

protocol HomeViewModelInputs {
    func retryFetch()
    func viewDidLoad()
    func refresh()
}

protocol HomeViewModelOutputs {
    var articles: Driver<[Article]> { get }
    var isFetching: Observable<Bool> { get }
    var error: Observable<Error> { get }
}

final class HomeViewModel: HomeViewModelProtocol, HomeViewModelInputs, HomeViewModelOutputs {

    private let viewDidLoadRelay = PublishRelay<Void>()
    private let refreshRelay = PublishRelay<Void>()
    private let retryFetchRelay = PublishRelay<Void>()

    private let disposeBag = DisposeBag()

    var input: HomeViewModelInputs { self }
    var output: HomeViewModelOutputs { self }

    let articles: Driver<[Article]>
    let isFetching: Observable<Bool>
    let error: Observable<Error>

    init(repository: NewsRepository = .init(), flux: Flux = .shared) {

        let newsActionCreator = flux.newsRepositoryActionCreator
        let newsStore = flux.newsRepositoryStore

        articles = newsStore.articles.asDriver()
        isFetching = newsStore.isFetching.asObservable()

        error = newsStore.error
            .flatMap { error -> Observable<Error> in
            guard let error = error as? NewsAPIError else { return .empty()}
                switch error {
                case let .decode(error), let .unknown(error):
                return .just(error)
                case .noResponse:
                    let error = NSError(domain: "サーバからの応答がありません。", code: -1, userInfo: nil)
                    return .just(error)
                 }
            }
            .share()

        Observable.merge(viewDidLoadRelay.asObservable(), refreshRelay.asObservable(), retryFetchRelay.asObservable())
            .subscribe(onNext: {
                newsActionCreator.fetch()
            })
            .disposed(by: disposeBag)
    }

    func viewDidLoad() { viewDidLoadRelay.accept(()) }
    func retryFetch() { retryFetchRelay.accept(()) }
    func refresh() { refreshRelay.accept(()) }
}
