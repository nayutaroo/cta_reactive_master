//
//  SignupViewModel.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/26.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa

protocol SignupViewModelType {
    var input: SignupViewModelInput { get }
    var output: SignupViewModelOutput { get }
}

protocol SignupViewModelInput {
    var username: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    func loginButtonTapped()
    func signupButtonTapped()
}

protocol SignupViewModelOutput {
    var transitionState: Driver<SignupViewModel.TransitionState> { get }
}

final class SignupViewModel: SignupViewModelType, SignupViewModelInput, SignupViewModelOutput {

    struct Dependency {
        var authrepository: AuthRepository
    }

    enum TransitionState {
        case initial
        case login
        case home
        case showAlert(message: String)
    }

    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

    private let loginButtonTappedRelay = PublishRelay<Void>()
    private let signupButtonTappedRelay = PublishRelay<Void>()

    let transitionStateRelay = BehaviorRelay<TransitionState>(value: .initial)
    var transitionState: Driver<TransitionState> {
        transitionStateRelay.asDriver()
    }

    private let dependency: Dependency
    private let disposeBag = DisposeBag()

    var input: SignupViewModelInput { self }
    var output: SignupViewModelOutput { self }

    init(dependency: Dependency) {
        self.dependency = dependency

        signupButtonTappedRelay
            .withLatestFrom(username)
            .filter { $0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.transitionStateRelay.accept(.showAlert(message: "Emailが未入力です"))
            })
            .disposed(by: disposeBag)

        signupButtonTappedRelay
            .withLatestFrom(password)
            .filter { $0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.transitionStateRelay.accept(.showAlert(message: "パスワードが未入力です"))
            })
            .disposed(by: disposeBag)

        let signupEvent = signupButtonTappedRelay
            .withLatestFrom(username)
            .withLatestFrom(password) { ($0, $1) } // optionalの場合はエラーを吐く....
            .filter { username, password in
                !username.isEmpty && !password.isEmpty
            }
            .flatMap { username, password in
                dependency.authrepository.signup(email: username, password: password)
                    .asObservable().materialize()
            }
            .share()

        signupEvent
            .flatMap { $0.element.map(Observable.just) ?? .empty() }
            .subscribe( Binder(self) { me, _ in
//                guard let authToken = token["token"] else { return }
//                me.dependency.keychainAccessRepository.save(token: authToken)
//                me.loginSucceededRelay.accept(())
                me.transitionStateRelay.accept(.home)
            })
            .disposed(by: disposeBag)

        signupEvent
            .flatMap { $0.error.map(Observable.just) ?? .empty() }
            .subscribe( Binder(self) { me, error in
                me.transitionStateRelay.accept(.showAlert(message: "サインアップに失敗しました"))
            })
            .disposed(by: disposeBag)

        loginButtonTappedRelay
            .map { _ in TransitionState.login }
            .bind(to: transitionStateRelay)
            .disposed(by: disposeBag)
    }

    func loginButtonTapped() { loginButtonTappedRelay.accept(()) }
    func signupButtonTapped() { signupButtonTappedRelay.accept(()) }
}
