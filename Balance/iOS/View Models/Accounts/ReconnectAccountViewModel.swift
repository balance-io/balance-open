//
//  ReconnectAccountViewModel.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/10/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ReconnectStatus {
    case validating
    case reconnect
}

enum RecconectViewState {
    case idle
    case validating(at: Int)
    case validationWasSucceeded(at: Int, message: String?)
    case validationWasFailed(at: Int, message: String?)
}

protocol AccountServices {
    var invalidInstitutions: [Institution] { get }
}

extension AccountServices {
    
    var totalInvalidAccounts: Int {
        return invalidInstitutions.count
    }
    
}

struct AccountServiceProvider: AccountServices {
    
    var invalidInstitutions: [Institution] {
        return InstitutionRepository.si.institutionsWithInvalidPasswords()
    }
    
}

struct ReconnectAccount {
    var name: String
    var status: ReconnectStatus
}

struct ReconnectAccountViewModel {
    
    var reconnectAccountViewModelState: Driver<RecconectViewState> {
        return reconnectAccountState.asDriver(onErrorJustReturn: .idle)
    }
    
    var totalReconnectAccounts: Int {
        return invalidInstitutions.reduce(0) { $0 + ($1.passwordInvalid ? 1 : 0) }
    }
    
    private var reconnectAccounts: [ReconnectAccount] {
        return invalidInstitutions.map { ReconnectAccount(name: $0.displayName,
                                                          status:  $0.onValidate ? .validating : .reconnect) }
    }
    
    private let reconnectAccountState = BehaviorSubject<RecconectViewState>(value: .idle)
    private var invalidInstitutions: [Institution] = {
        var array = [
            Institution.init(institutionId: 1, source: .kraken, sourceInstitutionId: "kraken", name: "kraken"),
            Institution.init(institutionId: 2, source: .poloniex, sourceInstitutionId: "poloniex", name: "poloniex"),
            Institution.init(institutionId: 3, source: .bitfinex, sourceInstitutionId: "bitfinex", name: "bitfinex")
        ]
        
        array.forEach { $0.passwordInvalid = true }
        
        return array
    }()
    
    init(services: AccountServices = AccountServiceProvider()) {
//        invalidInstitutions = services.invalidInstitutions
    }
    
    func action(at index: Int) -> (() -> Void)? {
        guard reconnectAccounts[safe: index] != nil else {
            return nil
        }
        
        return { self.reconnect(at: index) }
    }
    
    func reconnectAccount(at index: Int) -> ReconnectAccount? {
        return reconnectAccounts[safe: index]
    }
    
    func reconnect(at index: Int) {
        guard let invalidInstitution = invalidInstitutions[safe: index] else {
            print("Can't reconnect account at index: \(index)")
            return
        }
        
        invalidInstitution.onValidate = true
        reconnectAccountState.onNext(.validating(at: index))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            invalidInstitution.onValidate = false
            invalidInstitution.passwordInvalid = false
            self.reconnectAccountState.onNext(.validationWasSucceeded(at: index, message: "Example"))
        }
    }
    
}
