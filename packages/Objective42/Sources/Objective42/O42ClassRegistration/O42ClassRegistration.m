//
//  Created by Anton Spivak
//

#import "O42ClassRegistration.h"
#import "../NSException+O42.h"
#import "O42PatternReference.h"

@interface O42ClassRegistration ()

@property (nonatomic, readonly, assign) Class klass;
@property (nonatomic, readonly, assign) Class superklass;

@property (nonatomic, assign, getter=isKlassRegistered) BOOL klassRegistered;

@end

@implementation O42ClassRegistration

- (instancetype)initWithClassNamed:(NSString *)className
                   superclassNamed:(NSString *)superclassName
{
    self = [super init];
    if (self != nil) {
        Class superklass = NSClassFromString(superclassName);
        if (superklass == NULL) {
            [NSException o42_raiseExceptionWithName:NSGenericException
                                             reason:[NSString stringWithFormat:@"Class `%@` not found", className]
                                           userInfo:nil];
        }
        
        _superklass = superklass;
        _klass = objc_allocateClassPair(_superklass, [className UTF8String], 0);
        _klassRegistered = NO;
    }
    return self;
}

- (Class)registerClass {
    if (!self.isKlassRegistered) {
        objc_registerClassPair(self.klass);
    }
    
    return self.klass;
}

#pragma mark - Methods & Properties Registration

- (void)registerInstancePropertyWithReference:(O42PatternReference *)patternReference
                         getterExecutionBlock:(id)getterExecutionBlock
                         setterExecutionBlock:(id)setterExecutionBlock
{
    [self registrationExceptionIfNeeded];
    
    Class patternClass = patternReference.klass;
    
    unsigned attributeListCount;
    objc_property_t patternProperty = class_getProperty(patternClass, [patternReference.name UTF8String]);
    objc_property_attribute_t *attributeList = property_copyAttributeList(patternProperty, &attributeListCount);
    class_addProperty(self.klass, [patternReference.name UTF8String], attributeList, attributeListCount);
    free(attributeList);
    
    NSString *getterMethodName = patternReference.name;
    [self registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:getterMethodName klass:patternClass]
                               executionBlock:getterExecutionBlock];
    
    NSString *setterMethodName = [NSString stringWithFormat:@"set%@:", [patternReference.name capitalizedString]];
    [self registerInstanceMethodWithReference:[O42PatternReference referenceWithNamed:setterMethodName klass:patternClass]
                               executionBlock:setterExecutionBlock];
}

- (void)registerInstanceMethodWithReference:(O42PatternReference *)patternReference
                             executionBlock:(id)executionBlock
{
    [self registrationExceptionIfNeeded];
    
    SEL patternSelector = NSSelectorFromString(patternReference.name);
    const char *patternTypeEncoding = method_getTypeEncoding(class_getInstanceMethod(patternReference.klass, patternSelector));
    class_addMethod(self.klass, patternSelector, imp_implementationWithBlock(executionBlock), patternTypeEncoding);
}

#pragma mark - Private

- (void)registrationExceptionIfNeeded {
    if (!self.isKlassRegistered) {
        return;
    }
    
    [NSException o42_raiseExceptionWithName:NSGenericException
                                     reason:@"Class already registered and can not beiing modified."
                                   userInfo:nil];
}

@end
