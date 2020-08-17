
#import "KKDeviceManager.h"
#import "FMDB.h"

static NSString *DEVICE_LIST_SQLITE_NAME = @"deviceList.sqlite";
static KKDeviceManager *_singleInstance = nil;

@implementation KKDeviceManager {
    
    FMDatabaseQueue* queue;
}


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
            [self createTable];
        }
    });
    return _singleInstance;
}

- (void)createTable {
    
    // 获取文件路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbFilePath = [documentsPath stringByAppendingPathComponent:DEVICE_LIST_SQLITE_NAME];
    queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    // 创建表格
    [queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceTable ('number' integer primary key autoincrement not null, deviceID varchar(255), deviceName varchar(255), password varchar(255), securityCode varchar(255), imageFlip INTEGER, imageMirror INTEGER, infrared INTEGER, indicator INTEGER, beShared INTEGER, serverExist INTEGER, previewData blob, localIDsData blob);"];
        if (result) {
//                NSLog(@"~~~KK~~~ 创建数据库表格成功");
        }else{
            NSLog(@"~~~KK~~~ !!! 创建设备列表数据库表格失败");
        }
    }];
}


#pragma mark -


// 添加单个设备 (如果已有设备, 则先删除后插入)
- (void)addDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block {
        
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL success = NO;
        
        [db open];
        
        /* --- 1. 删除 --- */
        // 遍历查询所有设备,如果数据库中已含有此deviceID,则删除
        FMResultSet *res = [db executeQuery:@"SELECT * FROM deviceTable"];
        while ([res next]) {
            if ([device.did isEqualToString:[res stringForColumn:@"deviceID"]]) {
                NSString *sqlite = [NSString stringWithFormat:@"delete from deviceTable where deviceID = '%@'", device.did];
                success = [db executeUpdate:sqlite];
                break;
            }
        }
        
        /* --- 2.插入 --- */
        // NSArray转NSData
        NSData *localIDsData = [NSKeyedArchiver archivedDataWithRootObject:device.localIDs];
        // 准备sqlite语句
        NSString *sqlite = [NSString stringWithFormat:@"insert into deviceTable(deviceID, deviceName, password, securityCode, imageFlip, imageMirror, infrared, indicator, beShared, serverExist, previewData, localIDsData) values ('%@', '%@', '%@', '%@', '%d', '%d', '%d', '%d','%d', '%d', ?, ?)", device.did, device.name, device.pwd, device.securityCode, (int)device.imageFlip, (int)device.imageMirror, (int)device.infraredOn, (int)device.indicatorOn, (int)device.beShared, (int)device.serverExist];
        // 添加数据
        success = [db executeUpdate:sqlite, device.previewData, localIDsData];
        
        [db close];
        
        if (block) {
            block(success);
        }
    }];
}


// 移除单个设备
- (void)removeDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block {
        
    [queue inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        // 准备sqlite语句
        NSString *sqlite = [NSString stringWithFormat:@"delete from deviceTable where deviceID = '%@'", device.did];
        // 执行sqlite语句
        BOOL success =  [db executeUpdate:sqlite];
        
        [db close];

        if (block) {
            block(success);
        }
    }];
}


// 移除所有设备
- (void)removeAllDeviceFinishBlock:(nullable void (^) (BOOL success))block {
    
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        NSString *sqlstr = @"delete from deviceTable";
        BOOL success =  [db executeUpdate:sqlstr];
        
        [db close];
                
        if (block) {
            block(success);
        }
    }];
}


// 更新设备信息,顺便更新deviceList
- (void)updateDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block {
    
    
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL success = NO;
        
        [db open];
        
        // NSArray转NSData
        NSData *localIDsData = [NSKeyedArchiver archivedDataWithRootObject:device.localIDs];
        // 准备sqlite语句
        NSString *sqlite = [NSString stringWithFormat:@"update deviceTable set deviceName = '%@', password = '%@', securityCode = '%@', imageFlip = '%d', imageMirror = '%d', infrared = '%d', indicator = '%d', beShared = '%d', serverExist = '%d', previewData = ?, localIDsData = ? where deviceID = '%@'", device.name, device.pwd, device.securityCode, (int)device.imageFlip, (int)device.imageMirror, (int)device.infraredOn, (int)device.indicatorOn, (int)device.beShared, (int)device.serverExist, device.did];
        // 添加数据
        success = [db executeUpdate:sqlite, device.previewData, localIDsData];
        
        [db close];
        
        if (block) {
            block(success);
        }
    }];
}


// 获取设备列表
- (void)getDeviceListFinishBlock:(nullable void (^) (NSMutableArray<KKDevice *> *deviceList))block {
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        NSMutableArray *deviceList = [[NSMutableArray<KKDevice *> alloc] init];
        // 1.准备sqlite语句
        NSString *sqlite = [NSString stringWithFormat:@"select * from deviceTable"];
        // 2.执行查询语句
        FMResultSet *resultSet = [db executeQuery:sqlite];
        // 3.遍历结果
        while ([resultSet next]) {
                        
            KKDevice *device = [[KKDevice alloc] init];
            
            if (device) {
                
                device.name = [resultSet stringForColumn:@"deviceName"];
                device.pwd = [resultSet stringForColumn:@"password"];
                device.securityCode = [resultSet stringForColumn:@"securityCode"];
                device.imageFlip = [resultSet boolForColumn:@"imageFlip"];
                device.imageMirror = [resultSet boolForColumn:@"imageMirror"];
                device.infraredOn = [resultSet intForColumn:@"infrared"];
                device.indicatorOn = [resultSet boolForColumn:@"indicator"];
                device.beShared = [resultSet boolForColumn:@"beShared"];
                device.serverExist = [resultSet boolForColumn:@"serverExist"];
                device.previewData = [resultSet dataForColumn:@"previewData"];
                NSData *localIDsData = [resultSet dataForColumn:@"localIDsData"];
                device.localIDs = [NSKeyedUnarchiver unarchiveObjectWithData:localIDsData];
                
                [deviceList addObject:device];
            }
            
        }
        
        [db close];

        if (block) {
            block(deviceList);
        }
    }];
}


@end
