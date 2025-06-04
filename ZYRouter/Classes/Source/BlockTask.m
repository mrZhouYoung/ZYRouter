//
//  BlockTask.m
//  ZYRouter
//
//  Created by Young on 2024/12/28.
//

#import "BlockTask.h"
#import "ZYRouter.h"
#import <objc/runtime.h>

@implementation BlockTask

SYNTHESIZE_CONTEXT
SYNTHESIZE_PARAMS
SYNTHESIZE_OPTIONS
SYNTHESIZE_COMPLETIONHANDLER

- (void)excute {
    void (^block)(NSDictionary *params) = self.options[RoutesBlockKey];
    
    RouteContext *context = self.context;
    if (block) {
        block(self.params);
        if (context.task.completionHandler) {
            RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeOK message:[NSString stringWithFormat:@"route URL OK: %@", self.context.request.URL]];
            context.task.completionHandler(response);
        }
        [context removeFromParentContext];
    } else {
        RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeTaskExcutionError message:[NSString stringWithFormat:@"block not found for URL: %@", self.context.request.URL]];
        if (context.task.completionHandler) {
            context.task.completionHandler(response);
        }
        [context interrupt];
    }
}

@end
