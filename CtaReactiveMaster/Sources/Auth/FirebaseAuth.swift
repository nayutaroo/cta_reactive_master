//
//  FirebaseAuth.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/07.
//

import FirebaseAuth
import RxSwift

struct FirebaseAuth {

    func signup(email: String, password: String) -> Single<String> {
        Single<String>.create(subscribe: { observer in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                }

                guard let user = authResult?.user else {
                    observer(.failure(NSError(domain: "userがありません", code: -1, userInfo: nil)))
                    return
                }
                observer(.success(user.uid))
            }
            return Disposables.create()
        })
    }

    func login(email: String, password: String) -> Single<String> {
        Single<String>.create(subscribe: { observer in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                }

                guard let user = authResult?.user else {
                    observer(.failure(NSError(domain: "userがありません", code: -1, userInfo: nil)))
                    return
                }
                observer(.success(user.uid))
            }
            return Disposables.create()
        })
    }
}
