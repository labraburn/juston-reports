//
//  Created by Anton Spivak
//

#import "UIViewPropertyAnimator+SUI.h"

@implementation UIViewPropertyAnimator (SUI)

+ (BOOL)sui_trackingAnimationsCurrentlyEnabled {
    typedef BOOL (*function)(id, SEL);
    function block = (function)SUI_OBJC_MSG_SEND_STRET;
    return block(self, SUISelectorFromReversedStringParts(@"onsCurrentlyEnabled", @"_trackingAnimati", nil));
}

+ (NSUUID *)sui_currentTrackedAnimationsUUID {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:SUISelectorFromReversedStringParts(@"edAnimationsUUID", @"_currentTrack", nil)];
#pragma clang diagnostic pop
}

+ (void)sui_startTrackingAnimations {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:SUISelectorFromReversedStringParts(@"ngAnimations", @"_startTracki", nil)];
#pragma clang diagnostic pop
}

+ (void)sui_finishTrackingAnimations {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:SUISelectorFromReversedStringParts(@"ingAnimations", @"_finishTrack", nil)];
#pragma clang diagnostic pop
}

@end
