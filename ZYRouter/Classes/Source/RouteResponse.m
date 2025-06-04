//
//  ZYRouteresponse.m
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import "RouteResponse.h"

@implementation RouteResponse {
    int _code;
    NSString *_message;
}

- (instancetype)initWithCode:(int)code message:(NSString *)message {
    if (self = [super init]) {
        _code = code;
        _message = message;
    }
    return self;
}

- (int)code {
    return _code;
}

- (NSString *)message {
    return _message;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"RouteResponse code:%d message:%@", _code, _message];
}

@end
