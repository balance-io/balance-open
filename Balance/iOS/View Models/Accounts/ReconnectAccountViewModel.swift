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
    
    init(services: AccountServices = AccountServiceProvider()) {
        invalidInstitutions = services.invalidInstitutions
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.processResult(institutionId: invalidInstitution.institutionId, validationWasSucceeded: true)
        }
    }
    
    func processResult(institutionId: Int, validationWasSucceeded: Bool) {
        let institutionIndexBlock: (Institution) -> Bool = { $0.institutionId == institutionId }
        guard let institutionIndex = invalidInstitutions.index(where: institutionIndexBlock) else {
            print("Can't update institution with id: \(institutionId)")
            return
        }
        
        if !validationWasSucceeded {
            let invalidInstitution = invalidInstitutions[institutionIndex]
            invalidInstitution.onValidate = false
            reconnectAccountState.onNext(.validationWasFailed(at: institutionIndex,
                                                              message: "We can't update your account, please valid your fields and try again."))
            
            return
        }
        
        invalidInstitutions.remove(at: institutionIndex)
        reconnectAccountState.onNext(.validationWasSucceeded(at: institutionIndex, message: "Example"))
    }
    
}
