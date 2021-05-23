//
//  SideMenuViewModel.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/22.
//

import Foundation
import RxSwift

final class SideMenuViewModel {
    @PublishRelayInput var tapSearchButton: Observable<String>
    private let disposeBag = DisposeBag()

    init(flux: Flux = .shared) {
        let actionCreator = flux.newsRepositoryActionCreator
        let store = flux.newsRepositoryStore
    }
}
