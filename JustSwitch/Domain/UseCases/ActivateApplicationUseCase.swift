//
//  ActivateApplicationUseCase.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation

protocol ActivateApplicationUseCaseProtocol {
    func execute(application: Application)
}

class ActivateApplicationUseCase: ActivateApplicationUseCaseProtocol {
    
    private let applicationRepository: ApplicationRepositoryProtocol
    
    init(applicationRepository: ApplicationRepositoryProtocol) {
        self.applicationRepository = applicationRepository
    }
    
    func execute(application: Application) {
        applicationRepository.activateApplication(application)
    }
} 
