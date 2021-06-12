//
//  LoginViewModel.swift
//  hack_iOS
//
//  Created by 化田晃平 on R 3/03/26.
//

import Foundation
import RxCocoa
import RxSwift

protocol LoginViewModelType {
    var input: LoginViewModelInput { get }
    var output: LoginViewModelOutput { get }
}

protocol LoginViewModelInput {
    var username: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    func loginButtonTapped()
    func signupButtonTapped()
}

protocol LoginViewModelOutput {
    var transitionState: Driver<LoginViewModel.TransitionState> { get }
}

final class LoginViewModel: LoginViewModelType, LoginViewModelInput, LoginViewModelOutput {

    struct Dependency {
        var authrepository: AuthRepository
    }

    enum TransitionState {
        case initial
        case signup
        case home
        case showAlert(message: String)
    }

    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

    private let loginButtonTappedRelay = PublishRelay<Void>()
    private let signUpButtonTappedRelay = PublishRelay<Void>()

    private let loginSucceededRelay = PublishRelay<Void>()
    var loginSucceeded: Signal<Void> {
        loginSucceededRelay.asSignal()
    }

    let transitionStateRelay = BehaviorRelay<TransitionState>(value: .initial)
    var transitionState: Driver<TransitionState> {
        transitionStateRelay.asDriver()
    }

    private let dependency: Dependency
    private let disposeBag = DisposeBag()

    var input: LoginViewModelInput { self }
    var output: LoginViewModelOutput { self }

    init(dependency: Dependency) {
        self.dependency = dependency

        let loginEvent = loginButtonTappedRelay
            .withLatestFrom(username)
            .filter { !$0.isEmpty }
            .withLatestFrom(password) { ($0, $1) } // optionalの場合はエラーを吐く....
            .filter { !$1.isEmpty }
            .flatMap { username, password in
                dependency.authrepository.login(email: username, password: password)
                    .asObservable().materialize()
            }
            .share()

        loginButtonTappedRelay
            .withLatestFrom(username)
            .filter { $0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.transitionStateRelay.accept(.showAlert(message: "Emailが未入力です"))
            })
            .disposed(by: disposeBag)

        loginButtonTappedRelay
            .withLatestFrom(password)
            .filter { $0.isEmpty }
            .subscribe(Binder(self) { me, _ in
                me.transitionStateRelay.accept(.showAlert(message: "パスワードが未入力です"))
            })
            .disposed(by: disposeBag)

        loginEvent
            .flatMap { $0.element.map(Observable.just) ?? .empty() }
            .subscribe( Binder(self) { me, _ in
                me.transitionStateRelay.accept(.home)
            })
            .disposed(by: disposeBag)

        loginEvent
            .flatMap { $0.error.map(Observable.just) ?? .empty() }
            .subscribe( Binder(self) { me, error in
                me.transitionStateRelay.accept(.showAlert(message: "ログインに失敗しました"))
                print(error)
            })
            .disposed(by: disposeBag)

        signUpButtonTappedRelay
            .map { _ in TransitionState.signup }
            .bind(to: transitionStateRelay)
            .disposed(by: disposeBag)
    }

    func loginButtonTapped() { loginButtonTappedRelay.accept(()) }
    func signupButtonTapped() { signUpButtonTappedRelay.accept(()) }
}
