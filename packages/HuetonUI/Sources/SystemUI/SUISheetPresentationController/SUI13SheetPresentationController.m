//
//  SUI13SheetPresentationController.m
//  
//
//  Created by Anton Spivak on 09.02.2022.
//

#import "SUI13SheetPresentationController.h"
#import "SUISheetPresentationController.h"

#import <objc/message.h>
#import <objc/runtime.h>

static Class kSUI13SheetPresentationControllerClass = nil;
static Class kSUI13SheetPresentationControllerClass_ = nil;

@interface SUISheetPresentationControllerDetent (SUI13SheetPresentationController)

@property (nonatomic, copy) SUISheetPresentationControllerDetendIdentifier identifier;

@end

//
// Setters & Getters
//

static NSArray * SUI13PCDetentsGetter(UIPresentationController *self, SEL sel)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:SUISelectorFromReversedStringParts(@"nts", @"_dete", nil)];
#pragma clang diagnostic pop
}

static void SUI13PCDetentsSetter(UIPresentationController *self, SEL sel, NSArray *detents)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:SUISelectorFromReversedStringParts(@"nts:", @"_setDete", nil)
               withObject:detents];
#pragma clang diagnostic pop
}

static NSString * SUI13PCSelectedDetentIdentifierGetter(UIPresentationController *self, SEL sel)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSInteger index = [[self performSelector:SUISelectorFromReversedStringParts(@"rrentDetent", @"_indexOfCu", nil)] integerValue];
#pragma clang diagnostic pop
    
    if (index == NSNotFound) {
        return nil;
    }
    
    NSArray<SUISheetPresentationControllerDetent *> *detents = SUI13PCDetentsGetter(self, @selector(detents));
    return detents[index].identifier;
}

static void SUI13PCSelectedDetentIdentifierSetter(UIPresentationController *self, SEL sel, NSString *selectedDetentIdentifier)
{
    NSArray<SUISheetPresentationControllerDetent *> *detents = SUI13PCDetentsGetter(self, @selector(detents));
    NSInteger index = [detents indexOfObjectPassingTest:^BOOL(SUISheetPresentationControllerDetent *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:selectedDetentIdentifier];
    }];

    typedef void (*function)(id, SEL, NSInteger);
    function block = (function)objc_msgSend;
    block(self, SUISelectorFromReversedStringParts(@"xOfCurrentDetent:", @"_setInde", nil), index);
}

static NSString * SUI13PCLargestUndimmedDetentIdentifierGetter(UIPresentationController *self, SEL sel)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSInteger index = [[self performSelector:SUISelectorFromReversedStringParts(@"tUndimmedDetent", @"_indexOfLas", nil)] integerValue];
#pragma clang diagnostic pop
    
    if (index == NSNotFound) {
        return nil;
    }
    
    NSArray<SUISheetPresentationControllerDetent *> *detents = SUI13PCDetentsGetter(self, @selector(detents));
    return detents[index].identifier;
}

static void SUI13PCLargestUndimmedDetentIdentifierSetter(UIPresentationController *self, SEL sel, NSString *largestUndimmedDetentIdentifier)
{
    NSArray<SUISheetPresentationControllerDetent *> *detents = SUI13PCDetentsGetter(self, @selector(detents));
    NSInteger index = [detents indexOfObjectPassingTest:^BOOL(SUISheetPresentationControllerDetent *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:largestUndimmedDetentIdentifier];
    }];

    typedef void (*function)(id, SEL, NSInteger);
    function block = (function)objc_msgSend;
    block(self, SUISelectorFromReversedStringParts(@"astUndimmedDetent:", @"_setIndexOfL", nil), index);
}

static void * kSUI13PCShouldRespectPresentationContextKey = &kSUI13PCShouldRespectPresentationContextKey;

static BOOL SUI13PCShouldRespectPresentationContextGetter(UIPresentationController *self, SEL sel)
{
    return [objc_getAssociatedObject(self, kSUI13PCShouldRespectPresentationContextKey) boolValue];
}

static void SUI13PCShouldRespectPresentationContextSetter(UIPresentationController *self, SEL sel, BOOL shouldRespectPresentationContext)
{
    objc_setAssociatedObject(self, kSUI13PCShouldRespectPresentationContextKey, @(shouldRespectPresentationContext), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void * kSUI13PCShouldFullscreenKey = &kSUI13PCShouldFullscreenKey;

static BOOL SUI13PCShouldFullscreenGetter(UIPresentationController *self, SEL sel)
{
    return [objc_getAssociatedObject(self, kSUI13PCShouldFullscreenKey) boolValue];
}

static void SUI13PCShouldFullscreenSetter(UIPresentationController *self, SEL sel, BOOL shouldFullscreen)
{
    objc_setAssociatedObject(self, kSUI13PCShouldFullscreenKey, @(shouldFullscreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    typedef void (*function)(id, SEL, BOOL);
    function block = (function)objc_msgSend;
    block(self, SUISelectorFromReversedStringParts(@"tsFullScreen:", @"_setWan", nil), shouldFullscreen);
}

@implementation SUI13SheetPresentationController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSUI13SheetPresentationControllerClass = NSClassFromString(SUIReversedStringWithParts(@"tationController", @"_UISheetPresen", nil));
        kSUI13SheetPresentationControllerClass_ = objc_allocateClassPair(kSUI13SheetPresentationControllerClass, "_SUI13SheetPresentationController", 0);
        
        [self copyPropertyWithName:@"detents"
                           toClass:kSUI13SheetPresentationControllerClass_
                            setter:(IMP)SUI13PCDetentsSetter
                            getter:(IMP)SUI13PCDetentsGetter];
        
        [self copyPropertyWithName:@"selectedDetentIdentifier"
                           toClass:kSUI13SheetPresentationControllerClass_
                            setter:(IMP)SUI13PCSelectedDetentIdentifierSetter
                            getter:(IMP)SUI13PCSelectedDetentIdentifierGetter];
        
        [self copyPropertyWithName:@"largestUndimmedDetentIdentifier"
                           toClass:kSUI13SheetPresentationControllerClass_
                            setter:(IMP)SUI13PCLargestUndimmedDetentIdentifierSetter
                            getter:(IMP)SUI13PCLargestUndimmedDetentIdentifierGetter];
        
        [self copyPropertyWithName:@"shouldRespectPresentationContext"
                           toClass:kSUI13SheetPresentationControllerClass_
                            setter:(IMP)SUI13PCShouldRespectPresentationContextSetter
                            getter:(IMP)SUI13PCShouldRespectPresentationContextGetter];
        
        [self copyPropertyWithName:@"shouldFullscreen"
                           toClass:kSUI13SheetPresentationControllerClass_
                            setter:(IMP)SUI13PCShouldFullscreenSetter
                            getter:(IMP)SUI13PCShouldFullscreenGetter];
        
        [self addMethodWithSelector:@selector(performAnimatedChanges:)
                            toClass:kSUI13SheetPresentationControllerClass_
                              block:^(UIPresentationController *self, void (^changes)(void)) {
            UICubicTimingParameters *timingParameters = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveEaseOut];
            UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.28
                                                                                   timingParameters:timingParameters];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [animator addAnimations:^{
                changes();
                id layout = [self performSelector:SUISelectorFromReversedStringParts(@"utInfo", @"_layo", nil)];
                [layout performSelector:SUISelectorFromReversedStringParts(@"ut", @"_layo", nil)];
            }];
#pragma clang diagnostic pop
            [animator startAnimation];
        }];
        
        [self addMethodWithSelector:@selector(_shouldRespectDefinesPresentationContext)
                            toClass:kSUI13SheetPresentationControllerClass_
                              block:^BOOL (UIPresentationController *self) {
            return SUI13PCShouldRespectPresentationContextGetter(self, @selector(_shouldRespectDefinesPresentationContext));
        }];
        
        [self addMethodWithSelector:@selector(shouldPresentInFullscreen)
                            toClass:kSUI13SheetPresentationControllerClass_
                              block:^BOOL (UIPresentationController *self) {
            return !SUI13PCShouldRespectPresentationContextGetter(self, @selector(_shouldRespectDefinesPresentationContext));
        }];
        
        [self addMethodWithSelector:@selector(sheetInteraction:didChangeOffset:)
                            toClass:kSUI13SheetPresentationControllerClass_
                              block:^(UIPresentationController *self, id sheetInteraction, CGPoint contentOffset) {
            
            struct objc_super super = {
                .receiver = self,
                .super_class = class_getSuperclass([self class])
            };
            
            typedef void (*function)(struct objc_super *, SEL, id, CGPoint);
            function block = (function)objc_msgSendSuper;
            block(&super, @selector(sheetInteraction:didChangeOffset:), sheetInteraction, contentOffset);
            
            id delegate = self.delegate;

            // Getting real proxy object
            SUISheetPresentationController *rself = (id)[[self presentedViewController] presentationController];

            if ([delegate respondsToSelector:@selector(sheetPresentationController:didChangeOffset:inContainerView:)]) {
                [delegate sheetPresentationController:rself didChangeOffset:contentOffset inContainerView:self.containerView];
            }
        }];
        
        [self addMethodWithSelector:@selector(dimmingViewWasTapped:)
                            toClass:kSUI13SheetPresentationControllerClass_
                              block:^(UIPresentationController *self, UIView *dimmingView) {
            
            if ([self.presentedViewController.presentingViewController.presentationController isKindOfClass:[self class]]) {
                // Replicate iOS 15
                return;
            } else {
                struct objc_super super = {
                    .receiver = self,
                    .super_class = class_getSuperclass([self class])
                };
                
                typedef void (*function)(struct objc_super *, SEL, id);
                function block = (function)objc_msgSendSuper;
                block(&super, @selector(dimmingViewWasTapped), dimmingView);
            }
        }];
        
        objc_registerClassPair(kSUI13SheetPresentationControllerClass_);
    });
}

+ (void)copyPropertyWithName:(NSString *)propertyName
                     toClass:(Class)klass
                      setter:(IMP)setter
                      getter:(IMP)getter
{
    unsigned count;
    objc_property_attribute_t *properties = property_copyAttributeList(class_getProperty(self, [propertyName UTF8String]), &count);
    class_addProperty(klass, [propertyName UTF8String], properties, count);
    free(properties);
    
    SEL g_sel = NSSelectorFromString(propertyName);
    Method g_method = class_getInstanceMethod(self, g_sel);
    const char *g_types = method_getTypeEncoding(g_method);
    class_addMethod(klass, g_sel, (IMP)getter, g_types);
    
    SEL s_sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]]);
    Method s_method = class_getInstanceMethod(self, s_sel);
    const char *s_types = method_getTypeEncoding(s_method);
    class_addMethod(klass, s_sel, (IMP)setter, s_types);
}

+ (void)addMethodWithSelector:(SEL)selector
                      toClass:(Class)klass
                        block:(id)block
{
    Method method = class_getInstanceMethod(self, selector);
    const char *types = method_getTypeEncoding(method);
    NSAssert(class_addMethod(klass, selector, imp_implementationWithBlock(block), types), @"Can't add method to klass");
}

+ (instancetype)presentationControllerWithPresentedViewController:(UIViewController *)presentedViewController
                                         presentingViewController:(UIViewController *)presentingViewController
{
    return [[kSUI13SheetPresentationControllerClass_ alloc] initWithPresentedViewController:presentedViewController
                                                                   presentingViewController:presentingViewController];
}

// Just caps for type encoding
- (BOOL)_shouldRespectDefinesPresentationContext { return NO; }
- (BOOL)shouldPresentInFullscreen { return NO; }
- (void)performAnimatedChanges:(void (NS_NOESCAPE ^)(void))changes {};
- (void)sheetInteraction:(id)sheetInteraction didChangeOffset:(CGPoint)offset {}
- (void)dimmingViewWasTapped:(UIView *)dimmingView {}

@end
