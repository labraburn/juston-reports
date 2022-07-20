//
//  Created by Anton Spivak
//

#import "../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

SUI_EXPORT NSErrorDomain const SUISVGDecoderErrorDomain;

@interface SUISVGDecoder : NSObject

- (UIImage * _Nullable)decodeImageWithContentsOfURL:(NSURL *)fileURL
                                              error:(NSError * __autoreleasing *)error SUI_SWIFT_ERROR;

- (UIImage * _Nullable)decodeImageWithData:(NSData *)data
                                     error:(NSError * __autoreleasing *)error SUI_SWIFT_ERROR;

@end

NS_ASSUME_NONNULL_END
