//
//  BehaviorRelayOutput.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/25.
//

import RxRelay
import RxSwift

@propertyWrapper
final class BehaviorRelayOutput<Element> {

    fileprivate let relay: BehaviorRelay<Element>
    var wrappedValue: Element {
        get {
            relay.value
        }
        set {
            relay.accept(newValue)
        }
    }

    var projectedValue: Observable<Element> {
        relay.asObservable()
    }

    init(value: Element) {
        relay = .init(value: value)
    }
}

extension ObservableType {
    func bind(to relayWrapper: BehaviorRelayOutput<Element>) -> Disposable {
        bind(to: relayWrapper.relay)
    }
}
