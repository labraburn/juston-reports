//
//  Created by Anton Spivak
//

#import "O42PatternReference.h"

@implementation O42PatternReference

- (instancetype)initWithNamed:(NSString *)name
                        klass:(Class)klass;
{
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _klass = klass;
    }
    return self;
}

+ (instancetype)referenceWithNamed:(NSString *)name
                             klass:(Class)klass
{
    return [[O42PatternReference alloc] initWithNamed:name
                                                klass:klass];
}

@end
