//
//  LoginViewModel.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let submitTap = PublishRelay<Void>()

    let isEmailValid: Observable<Bool>
    let isPasswordValid: Observable<Bool>
    let isSubmitEnabled: Observable<Bool>
    let navigateToMain = PublishSubject<Void>() 

    private let disposeBag = DisposeBag()

    init() {
        isEmailValid = email.asObservable()
            .map { Validators.isValidEmail($0) }
            .share(replay: 1) 

        isPasswordValid = password.asObservable()
            .map { Validators.isValidPassword($0) }
            .share(replay: 1)

        isSubmitEnabled = Observable.combineLatest(isEmailValid, isPasswordValid)
            { $0 && $1 }
            .distinctUntilChanged()
            .share(replay: 1)

        submitTap
            .withLatestFrom(isSubmitEnabled)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                UserDefaultsManager.shared.isLoggedIn = true
                self?.navigateToMain.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
