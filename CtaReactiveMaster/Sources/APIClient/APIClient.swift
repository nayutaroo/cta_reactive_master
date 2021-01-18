//
//  APIClient.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation
import Alamofire

struct APIClient{
    let decoder = JSONDecoder()
    func request<T: Requestable>(_ request:T, completion: @escaping (Result<T.Response, NewsAPIError>) -> Void){
        print(request.url)
        
        AF.request(request.url).response { response in
            
            switch response.result {
            case .failure(let error):
                completion(.failure(NewsAPIError.unknown(error)))
                
            case .success(let data):
                guard let data = data else {
                    completion(.failure(NewsAPIError.noResponse))
                    return
                }
                do{
                    //dateの型の設定
                    decoder.dateDecodingStrategy = .iso8601
                    
                    // Responseはstaticなので T.をつけて利用
                    let model = try decoder.decode(T.Response.self, from: data)
                    completion(.success(model))
                }
                catch let error{
                    completion(.failure(NewsAPIError.decode(error)))
                    return
                }
            }
        }
    }
}
