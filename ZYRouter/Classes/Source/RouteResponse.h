//
//  RouteResponse.h
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ResponseCode) {
    ResponseCodeOK = 0,
    ResponseCodeURLNotFound,
    ResponseCodeInterceptorInstantiateError,
    ResponseCodeInterceptionFailed,
    ResponseCodeInterceptionPending,
    ResponseCodeInterceptionCancelled,
    ResponseCodeTaskInstantiateError,
    ResponseCodeTaskExcutionError
};

@class RouteContext;

@interface RouteResponse : NSObject

@property (nonatomic, readonly) int code;
@property (nonatomic, readonly) NSString *message;

@property (nonatomic, strong) RouteContext *context;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCode:(int)code message:(NSString *)message;

@end
