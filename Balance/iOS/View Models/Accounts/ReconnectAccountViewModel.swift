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
    case validating(accountIndex: Int, institution: Institution)
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

class ReconnectAccountViewModel {
    
    var reconnectAccountViewModelState: Driver<RecconectViewState> {
        return reconnectAccountState.asDriver(onErrorJustReturn: .idle)
    }
    
    var totalReconnectAccounts: Int {
        return invalidInstitutions.count
    }
    
    private var reconnectAccounts: [ReconnectAccount] {
        return invalidInstitutions.map { ReconnectAccount(name: $0.displayName,
                                                          status:  $0.onValidate ? .validating : .reconnect) }
    }

    private var invalidInstitutions: [Institution]
    private let reconnectAccountState = BehaviorSubject<RecconectViewState>(value: .idle)
    private let services: AccountServices
    
    init(services: AccountServices = AccountServiceProvider()) {
        self.services = services
        invalidInstitutions = services.invalidInstitutions
        
        let updateCoinbaseReconnectSelector = #selector(ReconnectAccountViewModel.updateCoinbaseReconnectAccount(with:))
        NotificationCenter.default.addObserver(self,
                                               selector: updateCoinbaseReconnectSelector,
                                               name: CoinbaseNotifications.autenticationDidFinish,
                                               object: nil)
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
    
    func updateReconnectedAccount(with institutionId: Int, wasSucceeded: Bool) {
        processResult(institutionId: institutionId, validationWasSucceeded: wasSucceeded)
    }
    
    func reconnect(at index: Int) {
        guard let invalidInstitution = invalidInstitutions[safe: index] else {
            print("Can't reconnect account at index: \(index)")
            return
        }
        
        reconnectAccountState.onNext(.validating(accountIndex: index, institution: invalidInstitution))
    }
    
}

private extension ReconnectAccountViewModel {
    
    func processResult(institutionId: Int, validationWasSucceeded: Bool, resultMessage: String? = nil) {
        let institutionIndexBlock: (Institution) -> Bool = { $0.institutionId == institutionId }
        guard let institutionIndex = invalidInstitutions.index(where: institutionIndexBlock) else {
            print("Can't update institution with id: \(institutionId)")
            return
        }
        
        if !validationWasSucceeded {
            let invalidInstitution = invalidInstitutions[institutionIndex]
            invalidInstitution.onValidate = false
            let message = resultMessage ?? "We can't update your account, please valid your fields and try again."
            
            reconnectAccountState.onNext(.validationWasFailed(at: institutionIndex,
                                                              message: message))
            
            return
        }
        
        invalidInstitutions.remove(at: institutionIndex)
        reconnectAccountState.onNext(.validationWasSucceeded(at: institutionIndex, message: "Your account was reconnected"))
    }
    
    @objc func updateCoinbaseReconnectAccount(with notification: Notification) {
        guard let result = CoinbaseNotifications.result(from: notification),
            let institutionId = result.institutionId else {
            print("Can't extract institution from notification with user info \((notification.userInfo ?? [:]))")
            return
        }
        
        let error = result.error
        let errorMessage = (error as? LocalizedError)?.recoverySuggestion ?? error?.localizedDescription
        let message = result.succeeded ? nil : errorMessage
        
        processResult(institutionId: institutionId, validationWasSucceeded: result.succeeded, resultMessage: message)
    }
    
}
