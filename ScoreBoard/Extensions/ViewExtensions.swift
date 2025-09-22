//
//  ViewExtensions.swift
//  ScoreBoard
//
//  Created by David Wang on 2025/9/22.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func `if`(_ condition: @autoclosure () -> Bool, transform: (Self) -> some View) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
