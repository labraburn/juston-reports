//
//  OnboardingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit

class OnboardingViewController: SteppableNavigationController {

    init() {
        super.init(rootViewModel: .initial)
    }
}

private extension SteppableViewModel {
    
    static var initial: SteppableViewModel {
        SteppableViewModel(
            title: "OnboardingInitialTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .image(
                            image: .hui_placeholder512
                        ),
                        .label(
                            text: "OnboardingInitialDescription".asLocalizedKey
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "OnboardingNextButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.next(.passcode)
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: true
        )
    }
    
    static var passcode: SteppableViewModel {
        SteppableViewModel(
            title: "OnboardingPasscodeTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .image(
                            image: .hui_placeholder512
                        ),
                        .label(
                            text: "OnboardingPasscodeDescription".asLocalizedKey
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .asynchronousButton(
                            title: "OnboardingCreateButton".asLocalizedKey,
                            kind: .primary,
                            action: { @MainActor viewController in
                                let passcode = PasscodeCreation(inside: viewController)
                                try await passcode.create()
                                viewController.next(.finish)
                            }
                        ),
                    ]
                )
            ],
            isModalInPresentation: true,
            isBackActionAvailable: true
        )
    }

    static var finish: SteppableViewModel {
        return SteppableViewModel(
            title: "OnboardingFinishTitle".asLocalizedKey,
            sections: [
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .image(
                            image: .hui_placeholder512
                        ),
                        .label(
                            text: "OnboardingFinishDescription".asLocalizedKey
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "OnboardingDoneButton".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                viewController.finish()
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: true,
            isBackActionAvailable: false
        )
    }
}
