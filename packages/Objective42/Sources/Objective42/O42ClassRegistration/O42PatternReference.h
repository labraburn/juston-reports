//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>

#import <objc/message.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface O42PatternReference : NSObject

@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, assign) Class klass;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)referenceWithNamed:(NSString *)name
                             klass:(Class)klass;

@end

NS_ASSUME_NONNULL_END
