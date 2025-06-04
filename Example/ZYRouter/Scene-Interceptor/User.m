//
//  User.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "User.h"

@implementation User {
    NSString *_uid;
    NSString *_token;
    NSString *_bankCardNumber;
    NSNumber *_realNameState;
    NSString *_name;
    NSString *_IDCardNumber;
    NSNumber *_riskLevel;
}

static User *user;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[self alloc] init];
    });
    return user;
}

- (BOOL)loginWithUid:(NSString *)uid token:(NSString *)token {
    if (uid.length > 0 && token.length > 0) {
        _uid = uid;
        _token = token;
        return YES;
    }
    
    return NO;
}

+ (BOOL)loginWithUid:(NSString *)uid token:(NSString *)token {
    return [[User shared] loginWithUid:uid token:token];
}

+ (void)logout {
    user = [[self alloc] init];
}

- (void)addBankCard:(NSString *)bankCardNumber {
    _bankCardNumber = bankCardNumber;
}
- (void)verifyWithName:(NSString *)name IDCardNumber:(NSString *)IDCardNumber {
    _name = name;
    _IDCardNumber = IDCardNumber;
    
    _realNameState = @(2);
}
- (void)riskLevelTestedAt:(NSNumber *)riskLevel {
    _riskLevel = riskLevel;
}

+ (instancetype)currentUser {
    if (user.uid.length > 0 && user.token.length > 0) {
        return user;
    }
    
    return nil;
}

@end
