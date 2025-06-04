//
//  RouteTaskProtocol.h
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#ifndef RouteTaskProtocol_h
#define RouteTaskProtocol_h

#define SYNTHESIZE_CONTEXT \
- (void)setContext:(RouteContext *)context {\
    objc_setAssociatedObject(self, @"context", context, OBJC_ASSOCIATION_ASSIGN);\
}\
- (RouteContext *)context {\
    return objc_getAssociatedObject(self, @"context");\
}

#define SYNTHESIZE_PARAMS \
- (void)setParams:(NSDictionary *)params {\
objc_setAssociatedObject(self, @"params", params, OBJC_ASSOCIATION_COPY_NONATOMIC);\
}\
- (NSDictionary *)params {\
return objc_getAssociatedObject(self, @"params");\
}

#define SYNTHESIZE_OPTIONS \
- (void)setOptions:(NSDictionary *)options {\
    objc_setAssociatedObject(self, @"options", options, OBJC_ASSOCIATION_COPY_NONATOMIC);\
}\
- (NSDictionary *)options {\
    return objc_getAssociatedObject(self, @"options");\
}

#define SYNTHESIZE_COMPLETIONHANDLER \
- (void)setCompletionHandler:(void (^)(RouteResponse *))completionHandler {\
    objc_setAssociatedObject(self, @"completionHandler", [completionHandler copy], OBJC_ASSOCIATION_COPY_NONATOMIC);\
}\
- (void (^)(RouteResponse *))completionHandler {\
    return objc_getAssociatedObject(self, @"completionHandler");\
}

@class RouteContext, RouteResponse;

@protocol RouteTaskProtocol <NSObject>

@property (nonatomic, weak) RouteContext *context;

@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic) void (^completionHandler)(RouteResponse *response);

@required
- (void)excute;

@end

#endif /* RouteTaskProtocol_h */
