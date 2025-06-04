
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "RouteInterceptor+last.h"

@implementation RouteInterceptor (last)

- (NSArray<RouteInterceptor *> *)relativeInterceptors {
    NSMutableArray *relativeInterceptors = [NSMutableArray arrayWithArray:self.context.interceptors];
    
    RouteContext *context = self.context.parentContext;
    while (context) {
        NSArray *interceptors = context.interceptors;
        if (interceptors.count > 0) {
            NSUInteger index = [interceptors indexOfObject:context.currentInterceptor];
            NSRange range = NSMakeRange(0, index);
            NSRange leftRange = NSMakeRange(index, interceptors.count-index);
            NSMutableArray *tmp = [NSMutableArray array];
            [tmp addObjectsFromArray:[interceptors subarrayWithRange:range]];
            [tmp addObjectsFromArray:relativeInterceptors];
            [tmp addObjectsFromArray:[interceptors subarrayWithRange:leftRange]];
            relativeInterceptors = tmp;
        }
        context = context.parentContext;
    }
    
    NSLog(@"%s %@", __func__, relativeInterceptors);
    
    return [relativeInterceptors copy];
}

- (BOOL)isLast {
    return self.relativeInterceptors.lastObject == self;
}

@end
