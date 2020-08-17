//
//  Person.h
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/13.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject <NSSecureCoding>

@property (nonatomic, copy)     NSString    *name;
@property (nonatomic, assign)   int         age;
@property (nonatomic, strong)   NSData      *headData;

@end

NS_ASSUME_NONNULL_END
