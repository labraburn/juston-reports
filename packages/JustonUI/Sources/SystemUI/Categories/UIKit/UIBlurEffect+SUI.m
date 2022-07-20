//
//  Created by Anton Spivak
//

#import "UIBlurEffect+SUI.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIBlurEffect (SUI)

+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius {
    return [self effectWithRadius:radius scale:1];
}

+ (UIBlurEffect *)effectWithRadius:(CGFloat)radius scale:(CGFloat)scale {
    SEL sel = SUISelectorFromReversedStringParts(@"urRadius:scale:", @"_effectWithBl", nil);
    typedef UIBlurEffect * (*function)(id, SEL, CGFloat, CGFloat);
    function block = (function)objc_msgSend;
    return block(self, sel, radius, scale);
}

+ (UIBlurEffect *)effectWithTintColor:(UIColor *)color {
    SEL sel = SUISelectorFromReversedStringParts(@"hTintColor:", @"_effectWit", nil);
    typedef UIBlurEffect * (*function)(id, SEL, UIColor *);
    function block = (function)objc_msgSend;
    return block(self, sel, color);
}

@end
