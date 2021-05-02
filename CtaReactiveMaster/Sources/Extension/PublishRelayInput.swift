//
//  PublishRelayInput.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/01.
//

import RxRelay
import RxSwift

@propertyWrapper
final class PublishRelayInput<Element> {

    fileprivate let relay: PublishRelay<Element>
    init() {
        relay = .init()
    }

    var wrappedValue: Observable<Element> {
        relay.asObservable()
    }

    var projectedValue: PublishRelay<Element> {
        relay
    }
}

extension PublishRelayInput {
    func accept(value: Element) {
        relay.accept(value)
    }
}
