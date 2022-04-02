//
//  Created by Anton Spivak
//

#import "SUISVGDecoder.h"

@import Objective42;

#import <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

NSErrorDomain const SUISVGDecoderErrorDomain = @"SUISVGDecoderErrorDomain;";

typedef struct CF_BRIDGED_TYPE(id) CGSVGDocument *CGSVGDocumentRef;

static void (*SUICGSVGDocumentRelease)(CGSVGDocumentRef);
static CGSVGDocumentRef (*SUICGSVGDocumentCreateFromData)(CFDataRef data, CFDictionaryRef options);

static NSData *kSUISVGDataTag = nil;

static inline NSString *SDBase64DecodedString(NSString *base64String) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation SUISVGDecoder

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SUICGSVGDocumentRelease = dlsym(RTLD_DEFAULT, SUIReversedStringWithParts(@"VGDocumentRelease", @"CGS", nil).UTF8String);
        SUICGSVGDocumentCreateFromData = dlsym(RTLD_DEFAULT, SUIReversedStringWithParts(@"VGDocumentCreateFromData", @"CGS", nil).UTF8String);
        kSUISVGDataTag = [@"</svg>" dataUsingEncoding:NSUTF8StringEncoding];
    });
}

- (UIImage *)decodeImageWithContentsOfURL:(NSURL *)fileURL
                                    error:(NSError *__autoreleasing  _Nullable *)error
{
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:kNilOptions error:error];
    if (data == nil) {
        return nil;
    }
    
    return [self decodeImageWithData:data error:error];
}

- (UIImage *)decodeImageWithData:(NSData *)data
                           error:(NSError *__autoreleasing  _Nullable *)error
{
    if (![self dataIsSVG:data error:error]) {
        return nil;
    }
    
    return [self imageWithData:data];
}

- (UIImage *)imageWithData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string == nil) {
        return nil;
    }
    
    if ([self containsUnsupportedConfiguration:string]) {
        return nil;
    }
    
    CGSVGDocumentRef document = SUICGSVGDocumentCreateFromData((__bridge CFDataRef)data, NULL);
    if (!document) {
        return nil;
    }
    
    typedef UIImage * _Nullable (*function)(id, SEL, CGSVGDocumentRef);
    function block = (function)objc_msgSend;
    
    UIImage *image = block([UIImage class], SUISelectorFromReversedStringParts(@"GSVGDocument:", @"_imageWithC", nil), document);
    SUICGSVGDocumentRelease(document);
    
    // Convert to PNG
    return [[UIImage alloc] initWithData:UIImagePNGRepresentation(image)];
}

- (BOOL)dataIsSVG:(NSData *)data
            error:(NSError *__autoreleasing  _Nullable *)error
{
    if (data == nil) {
        *error = [NSError errorWithDomain:SUISVGDecoderErrorDomain
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey : @"Data is nil"}];
        return NO;
    }
    
    NSRange range;
    @try {
        range = [data rangeOfData:kSUISVGDataTag
                          options:NSDataSearchBackwards
                            range:NSMakeRange(data.length - MIN(90, data.length), MIN(90, data.length))];
    } @catch (NSException *exception) {
        *error = [exception error];
        return NO;
    }
    
    if (range.location == NSNotFound) {
        *error = [NSError errorWithDomain:SUISVGDecoderErrorDomain
                                     code:0
                                 userInfo:@{NSLocalizedDescriptionKey : @"Data is not SVG"}];
        return NO;
    }
    
    return YES;
}

// Core SVG doesn't support any styles which contains 'opacity' and 'fill' colors simultaneously
- (BOOL)containsUnsupportedConfiguration:(NSString *)string {
    static NSRegularExpression *regex = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *p = @"(\\{|<)([^\\{\\}<>]+)?(((?=opacity)([^\\{\\}<>]+)?(?=fill))|((?=fill)([^\\{\\}<>]+)?(?=opacity)))([^\\{\\}<>]+)?(\\}|>)";
        regex = [NSRegularExpression regularExpressionWithPattern:p
                                                          options:kNilOptions
                                                            error:nil];
    });
    
    return [regex matchesInString:string options:kNilOptions range:NSMakeRange(0, string.length)];
}

@end
