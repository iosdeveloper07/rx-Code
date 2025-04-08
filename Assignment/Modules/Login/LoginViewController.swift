//
//  LoginViewController.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
    }

    private func setupUI() {
        title = "Login"
        submitButton.layer.cornerRadius = 8
        submitButton.isEnabled = false
    }

    private func setupBindings() {
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)

        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        viewModel.isSubmitEnabled
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        submitButton.rx.tap
            .bind(to: viewModel.submitTap)
            .disposed(by: disposeBag)

        viewModel.navigateToMain
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigateToMainScreen()
            })
            .disposed(by: disposeBag)

         viewModel.isSubmitEnabled
             .map { $0 ? 1.0 : 0.5 } 
             .bind(to: submitButton.rx.alpha)
             .disposed(by: disposeBag)
    }

    private func navigateToMainScreen() {
        guard let mainTabBarVC = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController else {
             let mainTabBarVC = MainTabBarController()
             guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window else { return }
             window.rootViewController = mainTabBarVC
             window.makeKeyAndVisible()
             return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        window.rootViewController = mainTabBarVC
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
