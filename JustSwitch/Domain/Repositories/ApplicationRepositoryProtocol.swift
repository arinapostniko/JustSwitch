//
//  ApplicationRepositoryProtocol.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation

protocol ApplicationRepositoryProtocol {
    func getRunningApplications() -> [Application]
    func activateApplication(_ application: Application)
} 