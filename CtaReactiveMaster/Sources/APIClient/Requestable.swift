//
//  requestable.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/01/15.
//

import Foundation

protocol Requestable {
    associatedtype Response: Decodable
    var url: URL { get }
}
