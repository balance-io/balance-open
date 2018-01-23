//
//  MockInstitutionRepository.swift
//  BalanceUnitTests
//
//  Created by Eli Pacheco Hoyos on 1/21/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation
@testable import BalancemacOS

class MockInstitutionRepository: InstitutionRepository {
    
    @discardableResult override func institution(institutionId: Int? = nil,
                                        source: Source,
                                        sourceInstitutionId: String,
                                        name: String,
                                        nameBreak: Int? = nil,
                                        primaryColor: PXColor? = nil,
                                        secondaryColor: PXColor? = nil,
                                        logoData: Data? = nil,
                                        dateAdded: Date = Date(),
                                        accessToken: String? = nil) -> Institution?
    {
        return Institution(institutionId: institutionId ?? -1,
                           source: source,
                           sourceInstitutionId: sourceInstitutionId,
                           name: name)
    }
    
}
