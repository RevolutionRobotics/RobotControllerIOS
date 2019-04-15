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
    var assembler: Assembler?
    var container: Container = Container()
}

// MARK: - Public methods
extension AssemblyRegister {
    func registerAssemblies() {
        assembler = Assembler(container: container)
        assembler?.apply(assemblies: [ServiceAssembly(), ScreenAssembly()])
    }
}
