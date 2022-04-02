//
//  Created by Anton Spivak
//

#import "SUINavigationControllerAnimatedTransitioning.h"
#import "SUINavigationControllerTransitionHandlerContainer.h"
#import "../Categories/UIKit/UIViewPropertyAnimator+SUI.h"

static Class kUINavigationParallaxTransitionClass = nil;
static Class kSUINavigationControllerAnimatedTransitioningClass = nil;

//
// kSUINCHandler
//

static void * kSUINCHandlerKey = &kSUINCHandlerKey;

static SUINavigationControllerTransitionHandlerContainer * _Nullable SUINCHandlerGetter(NSObject *self, SEL sel)
{
    return objc_getAssociatedObject(self, kSUINCHandlerKey);
}

static void SUINCHandlerSetter(NSObject *self, SEL sel, SUINavigationControllerTransitionHandlerContainer * _Nullable handler)
{
    objc_setAssociatedObject(self, kSUINCHandlerKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//
// SUINavigationControllerAnimatedTransitioning
//

@interface SUINavigationControllerAnimatedTransitioning ()

/// Dummy
@property (nonatomic, strong, nullable) SUINavigationControllerTransitionHandlerContainer *handlerContainer;

@end

@implementation SUINavigationControllerAnimatedTransitioning

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self registerClassPair];
    });
}

+ (void)registerClassPair {
    kUINavigationParallaxTransitionClass = NSClassFromString(SUIReversedStringWithParts(@"llaxTransition", @"_UINavigationPara", nil));
    kSUINavigationControllerAnimatedTransitioningClass = objc_allocateClassPair(kUINavigationParallaxTransitionClass, "_SUINavigationControllerAnimatedTransitioning", 0);
    
    [self copyPropertyWithName:@"handlerContainer"
                       toClass:kSUINavigationControllerAnimatedTransitioningClass
                        setter:(IMP)SUINCHandlerSetter
                        getter:(IMP)SUINCHandlerGetter];
    
    [self addMethodWithSelector:@selector(transitionDuration:)
                        toClass:kSUINavigationControllerAnimatedTransitioningClass
                          block:^NSTimeInterval (id self, id<UIViewControllerContextTransitioning> transitionContext) {
        SUINavigationControllerTransitionHandlerContainer *container = [self handlerContainer];
        return container.transitionDuration(transitionContext);
    }];
    
    [self addMethodWithSelector:@selector(animateTransition:)
                        toClass:kSUINavigationControllerAnimatedTransitioningClass
                          block:^(id self, id<UIViewControllerContextTransitioning> transitionContext) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:SUISelectorFromReversedStringParts(@"itionContext:", @"setTrans", nil) withObject:transitionContext];
#pragma clang diagnostic pop

        if (![UIViewPropertyAnimator sui_trackingAnimationsCurrentlyEnabled]) {
            [UIViewPropertyAnimator sui_startTrackingAnimations];
        }

        NSUUID *currentTrackedAnimationsUUID = [UIViewPropertyAnimator sui_currentTrackedAnimationsUUID];
        [self setValue:currentTrackedAnimationsUUID forKey:@"_currentTrackingAnimatorsAnimationsUUID"];

        SUINavigationControllerTransitionHandlerContainer *container = [self handlerContainer];
        container.transitionAnimation(transitionContext);
        
        if ([UIViewPropertyAnimator sui_trackingAnimationsCurrentlyEnabled]) {
            [UIViewPropertyAnimator sui_finishTrackingAnimations];
        }
    }];
    
    objc_registerClassPair(kSUINavigationControllerAnimatedTransitioningClass);
}

- (instancetype)initWithNavigationOperation:(UINavigationControllerOperation)navigationOperation
                         transitionDuration:(SUINavigationControllerTransitionDuration)transitionDuration
                        transitionAnimation:(SUINavigationControllerTransitionAnimation)transitionAnimation
{
    self = [[kSUINavigationControllerAnimatedTransitioningClass alloc] initWithCurrentOperation:navigationOperation];
    if (self != nil) {
        SUINavigationControllerTransitionHandlerContainer *container = [[SUINavigationControllerTransitionHandlerContainer alloc] init];
        container.transitionDuration = transitionDuration;
        container.transitionAnimation = transitionAnimation;
        
        // self not SUINavigationControllerAnimatedTransitioning but have all methods called here
        [self setHandlerContainer:container];
    }
    return self;
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

/// Dummy
- (instancetype)initWithCurrentOperation:(UINavigationControllerOperation)operation {}

/// Dummy
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {}

/// Dummy
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {}

@end
