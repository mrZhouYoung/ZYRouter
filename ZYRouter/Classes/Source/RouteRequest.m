//
//  RouteRequest.m
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import "RouteRequest.h"

@implementation RouteRequest

- (NSString *)description {
    return [NSString stringWithFormat:@"<RouteRequest: %p> URL: %@\nredirectFrom:%@\nparams:%@", self, self.URL, self.redirectFrom, self.params];
}

@end
