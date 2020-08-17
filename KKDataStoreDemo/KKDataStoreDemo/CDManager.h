//
//  CDManager.h
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/17.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Man+CoreDataClass.h"
#import "Man+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDManager : NSObject  {
    
    NSManagedObjectContext *_context;
}

+ (CDManager *)sharedInstance;

- (void)create;     // 创建数据库
- (void)addMan;     // 增
- (void)deleteMan;  // 删
- (void)updateMan;  // 改
- (void)readMan;    // 查

@end

NS_ASSUME_NONNULL_END
