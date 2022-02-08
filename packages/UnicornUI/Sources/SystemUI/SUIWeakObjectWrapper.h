//
//  Created by Anton Spivak
//

#import "SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUIWeakObjectWrapper<__covariant ObjectType> : NSObject

@property (nonatomic, nullable, weak) ObjectType wrappedObject;

@end

NS_ASSUME_NONNULL_END
