//
//  GetRunningApplicationsUseCase.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation

protocol GetRunningApplicationsUseCaseProtocol {
    func execute() -> [Application]
}

class GetRunningApplicationsUseCase: GetRunningApplicationsUseCaseProtocol {
    
    private let applicationRepository: ApplicationRepositoryProtocol
    
    init(applicationRepository: ApplicationRepositoryProtocol) {
        self.applicationRepository = applicationRepository
    }
    
    func execute() -> [Application] {
        applicationRepository.getRunningApplications()
    }
} 
