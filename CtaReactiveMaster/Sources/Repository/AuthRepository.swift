//
//  AuthRepository.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/06.
//

import Foundation

protocol AuthRepository {
    func login()
    func signup()
}

struct AuthRepositoryImpl: AuthRepository {
    func login() {}
    func signup() {}
}
