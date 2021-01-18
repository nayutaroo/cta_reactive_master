//
//  JSONDecoder+Extension.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/18.
//

import Foundation

extension JSONDecoder{
    
    //クロージャで.iso8601の言語設定をした上で定義
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
