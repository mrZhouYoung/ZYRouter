//
//  RouteRequest.h
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import <Foundation/Foundation.h>

@interface RouteRequest : NSObject

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *redirectFrom;
@property (nonatomic, strong) NSDictionary *params;

@end
