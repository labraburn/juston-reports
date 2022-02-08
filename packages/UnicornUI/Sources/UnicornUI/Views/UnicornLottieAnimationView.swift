//
//  File.swift
//
//
//  Created by Anton Spivak on 16.12.2021.
//

import Foundation

public final class UnicornLottieAnimationView: LottieAnimationView {
    public convenience init() {
        self.init(name: "unicorn-loader", in: .module)
    }
}
