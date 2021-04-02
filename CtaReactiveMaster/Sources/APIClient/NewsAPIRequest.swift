//
//  NewsAPIRequest.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation

//NewsAPIのエンドポイントのパス
enum Endpoint {
    case topHeadlines(Country, Category)
    case everything(Language)
    case sources(Country, Language, Category)
    
    func path() -> String {
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
        guard let filePath = Bundle.main.path(forResource: "Key", ofType: "plist")  else {
            //returnで返さずとも処理を停止させられる
            fatalError("can't get filepath")
        }
        
        //Key.plistのファイルの読み込みを行う
        let plist = NSDictionary(contentsOfFile: filePath)
        
        //object() -> String? -> String (as? は文字列以外でとった時用？)
        guard let value = plist?.object(forKey: "NewsAPIKey") as? String else {
            fatalError("Couldn't find key 'NewsAPIKey' in 'Key.plist'")
        }
        return value
    }
}


// APIClientのリクエストのジェネリックがRequestableを採用しているのでこちらにも記述
struct NewsAPIRequest : Requestable {
    typealias Response = News
    let endpoint: Endpoint
    var url: URL {
        var baseURL = URLComponents(string: "https://newsapi.org")!
        baseURL.path = endpoint.path()
        
        switch endpoint {
        //case文にletをつけると .~(この中の変数を仮引数のように宣言できる)
        case let .topHeadlines(country, category):
            baseURL.queryItems = [
                URLQueryItem(name: "country", value: country.rawValue),
                URLQueryItem(name: "category", value: category.rawValue),
                URLQueryItem(name: "apiKey", value: Key.newsApi)
            ]
            
        case let .everything(language):
            baseURL.queryItems = [
                URLQueryItem(name: "language", value: language.rawValue),
                URLQueryItem(name: "apiKey", value: Key.newsApi)
            ]
            
        case let .sources(country, language, category):
            baseURL.queryItems = [
                URLQueryItem(name: "country", value: country.rawValue),
                URLQueryItem(name: "language", value: language.rawValue),
                URLQueryItem(name: "category", value: category.rawValue),
                URLQueryItem(name: "apiKey", value: Key.newsApi)
            ]
        }
        return baseURL.url!
    }
}

//NewsAPIErrorの設定
enum NewsAPIError: Error {
    case decode(Error)
    case unknown(Error)
    case noResponse
}
