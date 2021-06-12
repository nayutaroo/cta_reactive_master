//
//  SignUpViewController.swift
//  hack_iOS
//
//  Created by 化田晃平 on R 3/03/12.
//

import RxCocoa
import RxSwift
import UIKit

final class SignupViewController: UIViewController, UITextFieldDelegate {

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

    @IBOutlet private weak var signupButton: RoundedButton! {
        didSet {
            signupButton.setTitle("Signup", for: .normal)
        }
    }

    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle("ログイン画面", for: .normal)
        }
    }

    private let authRepository: AuthRepository
    private let viewModel: SignupViewModelType
    private let disposeBag = DisposeBag()

    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
        self.viewModel = SignupViewModel(dependency: .init(authrepository: authRepository))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addRxObsserver()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        return true
    }

    private func addRxObsserver() {

        // input
        userNameTextField.rx.text.orEmpty
            .bind(to: viewModel.input.username)
            .disposed(by: disposeBag)

        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.input.password)
            .disposed(by: disposeBag)

        signupButton.rx.tap
            .bind(to: Binder(self) { me, _ in
                me.viewModel.input.signupButtonTapped()
            })
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .subscribe(Binder(self) { me, _ in
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
                case .login:
                    let rootVC = LoginViewController()
                    rootVC.modalPresentationStyle = .fullScreen
                    me.present(rootVC, animated: true)
                case .showAlert(let message):
                    me.showAlert(message: message)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
