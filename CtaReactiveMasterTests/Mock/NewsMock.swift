//
//  NewsMock.swift
//  CtaReactiveMasterTests
//
//  Created by 化田晃平 on R 3/05/11.
//

import Foundation
@testable import CtaReactiveMaster

private var _mock: News?
extension News {
    static var mock: News {
        if let mock = _mock { return mock }
        let data = JsonString.news.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let mock = try? decoder.decode(News.self, from: data) else {
            fatalError("can't read data")
        }
        _mock = mock
        return mock
    }
}
