//
//  LoginViewController.swift
//  hack_iOS
//
//  Created by 化田 晃平 on 2021/03/09.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var userNameTextField: UITextField! {
        didSet {
            userNameTextField.placeholder = "ユーザー名を入力"
            userNameTextField.delegate = self
        }
    }

    @IBOutlet private weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.placeholder = "パスワードを入力"
            passwordTextField.delegate = self
        }
    }

    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle("Login", for: .normal)
        }
    }

    @IBOutlet private weak var moveToSignUpViewButton: UIButton! {
        didSet {
            moveToSignUpViewButton.setTitle("SignupView", for: .normal)
        }
    }

    private let disposeBag = DisposeBag()
    private let viewModel: LoginViewModelType

    init(
        authRepository: AuthRepository = AuthRepositoryImpl()
    ) {
        self.viewModel = LoginViewModel(
            dependency: .init(authrepository: authRepository)
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        addRxObsserver()
    }

    private func addRxObsserver() {

        // input
        userNameTextField.rx.text.orEmpty.asObservable()
            .bind(to: viewModel.input.username)
            .disposed(by: disposeBag)

        passwordTextField.rx.text.orEmpty.asObservable()
            .bind(to: viewModel.input.password)
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .bind(to: Binder(self) { me, _ in
                me.viewModel.input.loginButtonTapped()
            })
            .disposed(by: disposeBag)

        // output
        viewModel.output.transitionState
            .drive( Binder(self) { me, state in
                switch state {
                case .home:
                    let rootVC = HomeViewController()
                    let navVC = UINavigationController(rootViewController: rootVC)
                    navVC.modalPresentationStyle = .fullScreen
                    me.present(navVC, animated: true)
                case .signup:
                    let rootVC = SignUpViewController()
                    let navVC = UINavigationController(rootViewController: rootVC)
                    navVC.modalPresentationStyle = .fullScreen
                    me.present(navVC, animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        // サインアップ画面へ遷移
        moveToSignUpViewButton.rx.tap
            .subscribe(Binder(self) { me, _ in
                me.viewModel.input.signupButtonTapped()
            })
            .disposed(by: disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        return true
    }
}
