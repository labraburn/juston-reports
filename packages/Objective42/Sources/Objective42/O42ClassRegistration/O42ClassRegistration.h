//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>

@class O42PatternReference;

NS_ASSUME_NONNULL_BEGIN

@interface O42ClassRegistration : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithClassNamed:(NSString *)className
                   superclassNamed:(NSString *)superclassName;

- (Class)registerClass;

- (void)registerInstancePropertyWithReference:(O42PatternReference *)patternReference
                         getterExecutionBlock:(id)getterExecutionBlock
                         setterExecutionBlock:(id)setterExecutionBlock;

- (void)registerInstanceMethodWithReference:(O42PatternReference *)patternReference
                             executionBlock:(id)executionBlock;

@end

NS_ASSUME_NONNULL_END
