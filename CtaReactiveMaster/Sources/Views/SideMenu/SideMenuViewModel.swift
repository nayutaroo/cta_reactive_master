//
//  SideMenuViewModel.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/22.
//

import Foundation
import RxRelay
import RxSwift

final class SideMenuViewModel {
    @PublishRelayInput var tapSearchButton: Observable<Void>
    let searchText = BehaviorRelay<String>(value: "")
    let isSearchable = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()

    init(flux: Flux = .shared) {
        let actionCreator = flux.newsRepositoryActionCreator

        tapSearchButton
            .withLatestFrom(searchText)
            .subscribe(onNext: { keyword in
                actionCreator.searchNews.accept(keyword)
            })
            .disposed(by: disposeBag)

        searchText
            .filter { $0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.isSearchable.accept(false)
            })
            .disposed(by: disposeBag)

        searchText
            .filter { !$0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.isSearchable.accept(true)
            })
            .disposed(by: disposeBag)
    }
}
