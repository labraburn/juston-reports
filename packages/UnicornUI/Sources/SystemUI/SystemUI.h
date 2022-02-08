//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if !defined(_SUI_EXPORT)
#   if defined(__cplusplus)
#       define _SUI_EXPORT extern "C"
#   else
#       define _SUI_EXPORT extern
#   endif
#endif

#define SUI_EXPORT _SUI_EXPORT

#if !defined(_SUI_SWIFT_ERROR)
#   if __OBJC__ && __has_attribute(swift_error)
#       define _SUI_SWIFT_ERROR __attribute__((swift_error(nonnull_error)));
#   else
#       abort();
#   endif
#endif

#define SUI_SWIFT_ERROR _SUI_SWIFT_ERROR

#define SUI_STATIC_INLINE static inline

#ifdef __cplusplus
#   define SUI_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#   define SUI_EXTERN extern __attribute__((visibility ("default")))
#endif

NS_ASSUME_NONNULL_BEGIN

/// Swizzle instance method of `aClass`
SUI_EXPORT void SUISwizzleInstanceMethodOfClass(Class aClass, SEL original, SEL swizzled);

/// Swizzle class method of `aClass`
SUI_EXPORT void SUISwizzleMethodOfClass(Class aClass, SEL original, SEL swizzled);

/// Returns string with reversed given substrings
/// Usable for hiding private API methods
SUI_EXPORT NSString *SUIReversedStringWithParts(NSString *firstPart, ...) NS_REQUIRES_NIL_TERMINATION;
/// Returns string with reversed given substrings array
/// Usable for hiding private API methods
SUI_EXPORT NSString *SUIReversedStringWithPartsArray(NSArray<NSString *> *parts);

SUI_EXPORT SEL SUISelectorFromReversedStringParts(NSString *firstPart, ...) NS_REQUIRES_NIL_TERMINATION;
SUI_EXPORT Class SUIClassFromReversedStringParts(NSString *firstPart, ...) NS_REQUIRES_NIL_TERMINATION;

NS_ASSUME_NONNULL_END
