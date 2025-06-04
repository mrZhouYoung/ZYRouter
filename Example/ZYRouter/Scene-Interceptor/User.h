//
//  User.h
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, readonly) NSString *token;


@property (nonatomic, copy) NSNumber *a;
@property (nonatomic, copy) NSNumber *b;
@property (nonatomic, copy) NSNumber *c;

/**
 -1: 过期；0: 未认证；1：已认证；2：认证中
 */
@property (nonatomic, copy) NSNumber *realNameState;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *IDCardNumber;

@property (nonatomic, readonly) NSString *bankCardNumber;

/**
 -1：过期；0：未测评；1：低风险；2：中风险；3：高风险
 */
@property (nonatomic, readonly) NSNumber *riskLevel;

+ (instancetype)currentUser;

+ (BOOL)loginWithUid:(NSString *)uid token:(NSString *)token;
+ (void)logout;

- (void)addBankCard:(NSString *)bankCardNumber;
- (void)verifyWithName:(NSString *)name IDCardNumber:(NSString *)IDCardNumber;
- (void)riskLevelTestedAt:(NSNumber *)riskLevel;

@end
