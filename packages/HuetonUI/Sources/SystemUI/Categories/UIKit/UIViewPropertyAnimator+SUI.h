//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewPropertyAnimator (SUI)

+ (BOOL)sui_trackingAnimationsCurrentlyEnabled;
+ (NSUUID *)sui_currentTrackedAnimationsUUID;

+ (void)sui_startTrackingAnimations;
+ (void)sui_finishTrackingAnimations;

@end

NS_ASSUME_NONNULL_END
