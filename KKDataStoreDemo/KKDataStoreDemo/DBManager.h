//
//  DBManager.h
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/14.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^DBCompletion)(BOOL success);


@interface DBManager : NSObject {
    
    NSString *databasePath;
}

+ (DBManager *)sharedInstance;

- (BOOL)createDB;

/// 添加
/// @param person person
/// @param completion block
- (void)addPerson:(Person *)person completion:(DBCompletion)completion;


/// 移除
/// @param person person
/// @param completion block
- (void)removePerson:(Person *)person completion:(DBCompletion)completion;


/// 获取
/// @param name 名字
/// @param completion block
- (void)getPersonWithName:(NSString *)name completion:(void (^)(Person * _Nullable person))completion;

@end

NS_ASSUME_NONNULL_END
