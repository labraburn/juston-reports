//
//  Created by Anton Spivak
//

#import "SystemUI.h"

#import <objc/runtime.h>

///
void SUISwizzleInstanceMethodOfClass(Class aClass, SEL original, SEL swizzled) {
    Method originalMethod = class_getInstanceMethod(aClass, original);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzled);
    BOOL didAddMethod =
    class_addMethod(aClass,
                    original,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

///
void SUISwizzleMethodOfClass(Class aClass, SEL original, SEL swizzled) {
    Method originalMethod = class_getClassMethod(aClass, original);
    Method swizzledMethod = class_getClassMethod(aClass, swizzled);
    
    Class mClass = object_getClass((id)aClass);
    
    BOOL didAddMethod =
    class_addMethod(mClass,
                    original,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(mClass,
                            swizzled,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/// Macro to convert va_args to array with starting frist element
#define va_args_array(array, first)                 \
    NSMutableArray *array = [NSMutableArray new];   \
    va_list ___args;                                \
    va_start(___args, first);                       \
    id ___arg = first;                              \
    while (___arg) {                                \
        [array addObject:___arg];                   \
        ___arg = va_arg(___args, id);               \
    }                                               \
    va_end(___args);                                \

///
NSString *SUIReversedStringWithParts(NSString *firstPart, ...) {
    va_args_array(array, firstPart);
    return SUIReversedStringWithPartsArray(array);
}

NSString *SUIReversedStringWithPartsArray(NSArray<NSString *> *parts) {
    return [[[parts reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
}

///
SEL SUISelectorFromReversedStringParts(NSString *firstPart, ...) {
    va_args_array(array, firstPart);
    return NSSelectorFromString(SUIReversedStringWithPartsArray(array));
}

///
Class SUIClassFromReversedStringParts(NSString *firstPart, ...) {
    va_args_array(array, firstPart);
    return NSClassFromString(SUIReversedStringWithPartsArray(array));
}
