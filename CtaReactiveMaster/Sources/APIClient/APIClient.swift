//
//  APIClient.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation
import RxSwift

struct APIClient {
    let decoder: JSONDecoder

    // 返り値にSingle型を用いるのは APIの結果を.success, .failureのいずれかで通知させたいから。
    // 加えてCompletionを流すときはMaybe, また, successを流さない場合はCompletable特性を利用する。
    // ちなみにエラーを返さなくても良い場合はDriver, Signal（Driverのreplayがない版）を利用する。
    func request<T: Requestable>(_ request: T) -> Single<T.Response> {
        Single<T.Response>.create(
            subscribe: { observer in
                let task = URLSession.shared.dataTask(with: request.url) { (data, response, error) in
                    if let error = error {
                        observer(.failure(APIError.unknown(error)))
                    }
                    guard response as? HTTPURLResponse != nil, let data = data else {
                        observer(.failure(APIError.noResponse))
                        return
                    }
                    do {
                        // Responseはstaticなので T.をつけて利用
                        let model = try decoder.decode(T.Response.self, from: data)
                        observer(.success(model))
                    }
                    catch let error {
                        observer(.failure(APIError.decode(error)))
                    }
                }
                task.resume()
                return Disposables.create()
            }
        )
    }
}
