//
//  CDManager.m
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/17.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "CDManager.h"
#import <CoreData/CoreData.h>


static CDManager *_singleInstance = nil;

@implementation CDManager

#pragma mark - 单例

+ (instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleInstance = [super allocWithZone:zone];
    });
    return _singleInstance;
}

- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleInstance = [super init];
        if (_singleInstance) {
            // 在这里初始化self的属性和方法
        }
    });
    return _singleInstance;
}


#pragma mark -

// 创建数据库
- (void)create {

    // 获取模型路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ManModel" withExtension:@"momd"];
    // 根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    // 利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    // 数据库的名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"coreData.sqlite"];
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    // 创建
    NSError *error = nil;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    if (error) {
        NSLog(@"创建数据库失败:%@",error);
    } else {
        NSLog(@"创建数据库成功");
    }

    // 创建上下文
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    // 关联持久化助理
    _context.persistentStoreCoordinator = store;
}


- (void)addMan {

    // new man
    Man *man = [NSEntityDescription insertNewObjectForEntityForName:@"Man" inManagedObjectContext:_context];
    man.name = @"name1";
    man.age = 11;
    NSString *headStr = @"不帅";
    man.headData = [headStr dataUsingEncoding:NSUTF8StringEncoding];

    // 保存
    NSError *error = nil;
    BOOL result = [_context save:&error];
    if (result == YES) {
        NSLog(@"添加成功");
    }else{
        NSLog(@"!!! 添加失败, error:%@", error);
    }
}


- (void)deleteMan {
   
    // 创建删除请求
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:@"Man"];
    // 删除条件
    deleRequest.predicate = [NSPredicate predicateWithFormat:@"age < %d", 10];
   
    // 发送请求, 返回需要删除的对象数组
    NSArray *deleArray = [_context executeFetchRequest:deleRequest error:nil];
    
    // 从数据库中删除
    for (Man *man in deleArray) {
        [_context deleteObject:man];
    }
   
    // 保存
    NSError *error = nil;
    BOOL result = [_context save:&error];
    if (result == YES) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"!!! 删除失败, error:%@", error);
    }
}


- (void)updateMan {
    
    // 创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Man"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", @"name1"];
    
    // 发送请求
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    
    // 修改
    for (Man *man in resArray) {
        man.age = 28;
    }
  
    // 保存
    NSError *error = nil;
    BOOL result = [_context save:&error];
    if (result == YES) {
        NSLog(@"更改成功");
    }else{
        NSLog(@"!!! 更改失败, error:%@", error);
    }
}


- (void)readMan {
    
    // 创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Man"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", @"name1"];

    // 发送请求
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    
    // 读取
    for (Man *man in resArray) {
        NSLog(@"name:%@, age:%d, headData:%@", man.name, (int)man.age, [[NSString alloc] initWithData:man.headData encoding:NSUTF8StringEncoding]);
    }
}


@end
