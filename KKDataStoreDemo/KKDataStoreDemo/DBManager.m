//
//  DBManager.m
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/14.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

static DBManager *_singleInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
static NSString *DB_SQLITE = @"people.db";
static NSString *DB_TABLE = @"personDetail";

@implementation DBManager


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

- (BOOL)createDB {
    
    BOOL isSuccess = YES;
    
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:DB_SQLITE]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:databasePath] == NO) {
        
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            
            NSString *sqliteStr = [NSString stringWithFormat:@"create table if not exists %@ (idx integer primary key autoincrement, name text, age integer, headData blob)", DB_TABLE];
            const char *sqliteChar = [sqliteStr UTF8String];
            char *errMsg;
            if (sqlite3_exec(database, sqliteChar, NULL, NULL, &errMsg) != SQLITE_OK) {
                
                isSuccess = NO;
                NSLog(@"!!! Failed to create table, errMsg:%s", errMsg);
            }
            sqlite3_close(database);
            
        }else {
            
            isSuccess = NO;
            NSLog(@"!!! Failed to open/create database");
        }
    }
    
    return isSuccess;
}


/// 添加
/// @param person person
/// @param completion block
- (void)addPerson:(Person *)person completion:(DBCompletion)completion {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *sqliteStr = [NSString stringWithFormat:@"insert into %@ (name, age, headData) values (?, ?, ?);", DB_TABLE];
        const char *sqliteChar = [sqliteStr UTF8String];
        int result = sqlite3_prepare_v2(database, sqliteChar, -1, &statement, nil);
        if (result == SQLITE_OK) {
            
            sqlite3_bind_text(statement, 1, [person.name UTF8String], -1, nil);
            sqlite3_bind_int(statement, 2, person.age);
            sqlite3_bind_blob(statement, 3, person.headData.bytes, (int)person.headData.length, nil);
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_finalize(statement);
                if (completion) completion(YES);
                return;
            }
        }
    }
    
    sqlite3_finalize(statement);
    if (completion) completion(NO);
}


/// 移除
/// @param person person
/// @param completion block
- (void)removePerson:(Person *)person completion:(DBCompletion)completion {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *sqliteStr = [NSString stringWithFormat:@"delete from %@ where name = \"%@\"", DB_TABLE, person.name];
        const char *sqliteChar = [sqliteStr UTF8String];
        int result = sqlite3_prepare_v2(database, sqliteChar, -1, &statement, nil);
        if (result == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_finalize(statement);
                if (completion) completion(YES);
                return;
            }
        }
    }
    
    sqlite3_finalize(statement);
    if (completion) completion(NO);
}


/// 获取
/// @param name 名字
/// @param completion block
- (void)getPersonWithName:(NSString *)name completion:(void (^)(Person *person))completion {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {

        NSString *sqliteStr = [NSString stringWithFormat:@"select * from %@ where name=\"%@\"", DB_TABLE, name];
        const char *sqliteChar = [sqliteStr UTF8String];
        int result = sqlite3_prepare_v2(database, sqliteChar, -1, &statement, nil);
        if (result == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Person *person = [Person new];
                person.name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                person.age = sqlite3_column_int(statement, 2);
                const char *dataBuffer = sqlite3_column_blob(statement, 3);
                int dataSize = sqlite3_column_bytes(statement, 3);
                person.headData = [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
                if ([person.name isEqualToString:name]) {
                    sqlite3_finalize(statement);
                    if (completion) completion(person);
                    return;
                }
            }
        }
    }
    
    sqlite3_finalize(statement);
    if (completion) completion(nil);
}


@end
