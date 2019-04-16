//
//  AssemblyRegister.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Swinject

final class AssemblyRegister {
    // MARK: - Properties
    private var assembler: Assembler = Assembler(container: AppContainer.shared.container)
}

// MARK: - Public methods
extension AssemblyRegister {
    func registerAssemblies() {
        assembler.apply(assemblies: [ServiceAssembly(), ScreenAssembly()])
    }
}
