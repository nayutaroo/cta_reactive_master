//
//  NewsAPIRequest.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation

//NewsAPIのエンドポイントのパス
enum Endpoint{
    case topHeadlines
    case everything
    case sources
    
    func endPoint() -> String{
        switch self {
        case .topHeadlines:
            return "/v2/top-headlines"
        case .everything:
            return "/v2/everything"
        case .sources:
            return "/v2/sources"
        }
    }
}

//APIKeyを自身のプロジェクトから取り出す
enum Key {
    static var newsApi: String {
        //プロジェクト内のKey.plistのパスを取得
        guard let filePath = Bundle.main.path(forResource: "Key", ofType: "plist")  else{
            //returnで返さずとも処理を停止させられる
            fatalError("can't get filepath")
        }
        
        //Key.plistのファイルの読み込みを行う
        let plist = NSDictionary(contentsOfFile: filePath)
        
        //object() -> String? -> String (as? は文字列以外でとった時用？)
        guard let value = plist?.object(forKey: "NewsAPIKey") as? String else {
            fatalError("Couldn't find key 'newsAPIKey' in 'Key.plist'")
        }
        return value
    }
}


// APIClientのリクエストのジェネリックがRequestableを採用しているのでこちらにも記述
struct NewsAPIRequest : Requestable{
    typealias Response = News
    var endpoint: Endpoint
    var url: URL {
        var baseURL = URLComponents(string: "https://newsapi.org")
        baseURL?.path = endpoint.endPoint()
        
        baseURL?.queryItems = [
            // カテゴリーを絞ると結果が0個になる可能性があるので指定しない
            //            URLQueryItem(name: "category", value: "business"),
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: Key.newsApi)
        ]
        guard let url = baseURL?.url else { fatalError("can't make url") }
        return url
    }
}

//NewsAPIErrorの設定
enum NewsAPIError: Error{
    case decode(Error)
    case unknown(Error)
    case noResponse
}
