//
//  AuthRepository.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/06.
//

import Foundation
import RxSwift

protocol AuthRepository {
    func login(email: String, password: String) -> Single<String>
    func signup(email: String, password: String) -> Single<String>
}

struct AuthRepositoryImpl: AuthRepository {
    let firebaseAuth: FirebaseAuth = .init()
    func signup(email: String, password: String) -> Single<String> {
        return firebaseAuth.signup(email: email, password: password)
    }
    func login(email: String, password: String) -> Single<String> {
        return firebaseAuth.login(email: email, password: password)
    }
}
