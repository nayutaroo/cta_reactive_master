//
//  FluxMock.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/11.
//

@testable import CtaReactiveMaster

extension Flux {
    static func mock(newsRepositoryMock: NewsRepositoryMock = .init()) -> Flux {
        let newsRepositoryActionCreator: NewsRepositoryActionCreator = .init(repository: newsRepositoryMock)
        let newsRepositoryDispatcher: NewsRepositoryDispatcher = .init()
        let newsRepositoryStore: NewsRepositoryStore = .init()

        return .init(
            newsRepositoryActionCreator: newsRepositoryActionCreator,
            newsRepositoryDispatcher: newsRepositoryDispatcher,
            newsRepositoryStore: newsRepositoryStore
        )
    }
}
