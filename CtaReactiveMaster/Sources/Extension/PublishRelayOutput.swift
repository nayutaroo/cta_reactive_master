//
//  PublishRelayOutput.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/01.
//

import RxRelay
import RxSwift

@propertyWrapper
final class PublishRelayOutput<Element> {

    fileprivate let relay: PublishRelay<Element>

    var wrappedValue: Observable<Element> {
        relay.asObservable()
    }

    init() {
        relay = .init()
    }
}

extension ObservableType {
    func bind(to relayWrapper: PublishRelayOutput<Element>) -> Disposable {
        bind(to: relayWrapper.relay)
    }
}
