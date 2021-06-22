//
//  SideMenuViewController.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/16.
//

import RxGesture
import RxRelay
import RxSwift
import UIKit

protocol SideMenuViewControllerDelegate: AnyObject {
    func parentViewControllerForSideMenuViewController(_ sideMenuViewController: SideMenuViewController) -> UIViewController
    func shouldPresentForSideMenuViewController(_ sideMenuViewController: SideMenuViewController) -> Bool
    func sideMenuViewControllerDidRequestShowing(_ sideMenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool)
    func sideMenuViewControllerDidRequestHiding(_ sideMenuViewController: SideMenuViewController, animated: Bool)
}

class SideMenuViewController: UIViewController {

    private let contentView: UIView = .init(frame: .zero)
    private(set) var textField: UITextField = .init(frame: .zero)
    private(set) var button: UIButton = .init(frame: .zero)

    private let disposeBag = DisposeBag()
    weak var delegate: SideMenuViewControllerDelegate?

    private var beganLocation: CGPoint = .zero
    private var beganState: Bool = false

    private let viewModel: SideMenuViewModel

    private var contentMaxWidth: CGFloat {
        return view.bounds.width * 0.8
    }

    private var isShown: Bool {
        self.parent != nil
    }

    init(viewModel: SideMenuViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addRxObserver()
    }

    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentRatio = 1.0
            }
        } else {
            contentRatio = 1.0
        }
    }

    func hideContentView(animated: Bool, completion: ((Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentRatio = 0
            }, completion: { (finished) in
                completion?(finished)
            })
        } else {
            contentRatio = 0
            completion?(true)
        }
    }

    func startPanGestureRecognizing() {
        if let parentViewController = self.delegate?.parentViewControllerForSideMenuViewController(self) {
            let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
            screenEdgePanGestureRecognizer.edges = [.left]
            parentViewController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)

            let panGestureRecognizer = UIPanGestureRecognizer()
            parentViewController.view.addGestureRecognizer(panGestureRecognizer)

            let screenEdgePanGestureObservable = screenEdgePanGestureRecognizer.rx.event.asObservable()
                .map { $0 as UIPanGestureRecognizer }
            let panGestureObservable = panGestureRecognizer.rx.event.asObservable()

            Observable.merge(screenEdgePanGestureObservable, panGestureObservable)
                .withUnretained(self)
                .subscribe(onNext: { me, recognizer in
                    me.handledPanGestureRecognizer(recognizer)
                })
                .disposed(by: disposeBag)
        }
    }

    private var contentRatio: CGFloat {
        get {
            return contentView.frame.maxX / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            contentView.frame.origin.x = contentMaxWidth * ratio - contentView.frame.width
            view.backgroundColor = UIColor(white: 0, alpha: 0.3 * ratio)
        }
    }

    private func addRxObserver() {

        textField.rx.text.orEmpty.asObservable()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe( Binder(self) { me, _ in
                me.textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        button.rx.tap
            .bind(to: Binder(self) { me, _ in
                me.viewModel.$tapSearchButton.accept(())
                me.hideContentView(animated: true) { [weak self] _ in
                    guard let me = self else { return }
                    me.willMove(toParent: nil)
                    me.removeFromParent()
                    me.view.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)

        view.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .filter { me, gesture in
                return gesture.location(in: me.contentView).x > me.contentView.bounds.maxX
            }
            .subscribe(onNext: { me, _ in
                me.tapBackground()
            })
            .disposed(by: disposeBag)
    }

    private func setupView() {

        var contentRect = view.bounds
        contentRect.size.width = contentMaxWidth
        contentRect.origin.x = -contentMaxWidth
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleHeight
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 3.0
        contentView.layer.shadowOpacity = 0.8
        view.addSubview(contentView)

        textField.frame.size.width = 200
        textField.frame.size.height = 40
        textField.frame.origin.x = view.bounds.width * 0.2 + 10
        textField.frame.origin.y = 50

        textField.placeholder = "検索"
        textField.keyboardType = .default
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.clearButtonMode = .always
        contentView.addSubview(textField)

        button.frame.size.width = 100
        button.frame.size.height = 50
        button.frame.origin.x = view.bounds.width * 0.2 + 100
        button.frame.origin.y = 120
        button.backgroundColor = .cyan
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("検索", for: .normal)
        contentView.addSubview(button)
    }

    private func tapBackground() {
        hideContentView(animated: true) { [weak self] _ in
            guard let me = self else { return }
            me.willMove(toParent: nil)
            me.removeFromParent()
            me.view.removeFromSuperview()
        }
    }

    private func handledPanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let shouldPresent = self.delegate?.shouldPresentForSideMenuViewController(self), shouldPresent else {
            return
        }

        let translation = panGestureRecognizer.translation(in: view)
        if translation.x > 0 && contentRatio == 1.0 {
            return
        }

        let location = panGestureRecognizer.location(in: view)
        switch panGestureRecognizer.state {
        case .began:
            beganState = isShown
            beganLocation = location
            if translation.x >= 0 {
                self.delegate?.sideMenuViewControllerDidRequestShowing(self, contentAvailability: false, animated: false)
            }
        case .changed:
            let distance = beganState ? beganLocation.x - location.x : location.x - beganLocation.x
            if distance >= 0 {
                let ratio = distance / (beganState ? beganLocation.x : (view.bounds.width - beganLocation.x))
                let contentRatio = beganState ? 1 - ratio : ratio
                self.contentRatio = contentRatio
            }

        case .ended, .cancelled, .failed:
            if contentRatio <= 1.0, contentRatio >= 0 {
                if location.x > beganLocation.x {
                    showContentView(animated: true)
                } else {
                    self.delegate?.sideMenuViewControllerDidRequestHiding(self, animated: true)
                }
            }
            beganLocation = .zero
            beganState = false
        default:
            break
        }
    }
}
