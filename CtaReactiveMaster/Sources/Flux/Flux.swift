//
//  Flux.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/04/02.
//

import Foundation

final class Flux {
    static let shared = Flux()

    let newsRepositoryActionCreator: NewsRepositoryActionCreator
    let newsRepositoryDispatcher: NewsRepositoryDispatcher
    let newsRepositoryStore: NewsRepositoryStore

    init(
        newsRepositoryActionCreator: NewsRepositoryActionCreator = .shared,
        newsRepositoryDispatcher: NewsRepositoryDispatcher = .shared,
        newsRepositoryStore: NewsRepositoryStore = .shared
    ) {
        self.newsRepositoryActionCreator = newsRepositoryActionCreator
        self.newsRepositoryDispatcher = newsRepositoryDispatcher
        self.newsRepositoryStore = newsRepositoryStore
    }
}
