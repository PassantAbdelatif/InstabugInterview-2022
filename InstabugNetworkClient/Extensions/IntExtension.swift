//
//  IntExtension.swift
//  InstabugNetworkClient
//
//  Created by Passant Abdelatif on 22/10/2022.
//

import Foundation

extension Int {
    var isLessThan1MB: Bool {
        return Int64(self) < 1048576
    }
    var isMoreThan1000Record: Bool {
        return self > 1000
    }
}
