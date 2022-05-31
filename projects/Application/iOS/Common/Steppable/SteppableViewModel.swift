//
//  SteppableViewModel.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonCORE

@MainActor
struct SteppableViewModel {
    
    struct SectionViewModel {
        
        let section: SteppableSection
        let items: [SteppableItem]
    }
    
    let title: String
    let sections: [SectionViewModel]
    
    let isModalInPresentation: Bool
    let isBackActionAvailable: Bool
}
