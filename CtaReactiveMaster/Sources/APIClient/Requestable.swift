//
//  requestable.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation

protocol Requestable {
//    associatedtype
//    protocolにおけるジェネリック
//    protocolを採用するものはassociatedtypeで指定したものに対して型を決定させる
    
    associatedtype Response: Decodable
    var url: URL { get }
}
