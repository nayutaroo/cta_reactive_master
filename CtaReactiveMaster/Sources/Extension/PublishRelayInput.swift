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
    fileprivate let observable: Observable<Element>

    var wrappedValue: Observable<Element> {
        relay.asObservable()
    }

    var projectedValue: PublishRelay<Element> {
        relay
    }

    init() {
        relay = .init()
        observable = relay.asObservable()
    }
}
