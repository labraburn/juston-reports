//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>

// O42_EXPORT
#if !defined(_O42_EXPORT)
#   if defined(__cplusplus)
#       define _O42_EXPORT extern "C"
#   else
#       define _O42_EXPORT extern
#   endif
#endif
#define O42_EXPORT _O42_EXPORT

// O42_SWIFT_ERROR
#if !defined(_O42_SWIFT_ERROR)
#   if __OBJC__ && __has_attribute(swift_error)
#       define _O42_SWIFT_ERROR __attribute__((swift_error(nonnull_error)));
#   else
#       abort();
#   endif
#endif
#define O42_SWIFT_ERROR _O42_SWIFT_ERROR

// O42_STATIC_INLINE
#define O42_STATIC_INLINE static inline

// O42_EXTERN
#ifdef __cplusplus
#   define O42_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#   define O42_EXTERN extern __attribute__((visibility ("default")))
#endif

// O42_OBJC_MSG_SEND_STRET
#if defined(__arm64__)
#   define O42_OBJC_MSG_SEND_STRET objc_msgSend
#else
#   define O42_OBJC_MSG_SEND_STRET objc_msgSend_stret
#endif
