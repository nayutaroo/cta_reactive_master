//
//  FluxMock.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/11.
//

@testable import CtaReactiveMaster

extension Flux {
    static func mock(newsRepositoryMock: NewsRepositoryMock = .init()) -> Flux {
        let newsRepositoryDispatcher = NewsRepositoryDispatcher()
        let newsRepositoryActionCreator = NewsRepositoryActionCreator(
            dispatcher: newsRepositoryDispatcher,
            repository: newsRepositoryMock
        )
        let newsRepositoryStore = NewsRepositoryStore(
            dispatcher: newsRepositoryDispatcher
        )

        return .init(
            newsRepositoryActionCreator: newsRepositoryActionCreator,
            newsRepositoryDispatcher: newsRepositoryDispatcher,
            newsRepositoryStore: newsRepositoryStore
        )
    }
}
