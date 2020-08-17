//
//  ViewController.m
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/13.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "DBManager.h"
#import "CDManager.h"

@interface ViewController ()

// 校验数据
@property (nonatomic, strong)   NSData      *archivedData;
// 文件路径
@property (nonatomic, copy)     NSString    *filePath;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fileHandle];
    [self writeToFile];
    [self userDefaults];
    [self keyedArchiver];
    [self bundle];
    [self keychain];
    [self ioFile];
    [self sqlite];
    [self coreData];
}


- (void)fileHandle {

    // 使用 NSFileManager 创建一个带初始内容的文件
    NSFileManager *manager = [NSFileManager defaultManager];
    // 待写入内容1
    NSString *fileStr1 = @"Hello";
    NSData *fileData1 = [fileStr1 dataUsingEncoding:NSUTF8StringEncoding];
    // 写入的文件路径
    NSString *filePath = [NSString stringWithFormat:@"%@/test.txt", NSTemporaryDirectory()];
    // 创建文件
    if(![manager fileExistsAtPath:filePath]) {
        [manager createFileAtPath:filePath      // 文件路径
                         contents:fileData1     // 初始化的内容
                       attributes:nil];         // 附加信息,一般置为nil
    }

    // 使用 NSFileHandle 继续写入内容
    // 只读权限打开
    __unused NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    // 只写权限打开
    __unused NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    // 读写权限打开
    NSFileHandle *updateHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    // 待写入内容2
    NSString *fileStr2 = @" World!";
    NSData *fileData2 = [fileStr2 dataUsingEncoding:NSUTF8StringEncoding];
    // 移动游标到末尾
    [updateHandle seekToEndOfFile];
    // 再写入一段内容
    [updateHandle writeData:fileData2];
    
    // 读取
    NSString *readStr = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"readStr:%@", readStr);
}

// ---------------------------------------------
//log:
//2020-08-17 17:04:39.049061+0800 KKDataStoreDemo[2116:76170] readStr:Hello World!


- (void)writeToFile {
    
    // 待写入的字符串
    NSString *plistStr = @"Hello World!";
    // 写入的文件路径
    NSString *filePath1 = [NSString stringWithFormat:@"%@/test.plist", NSTemporaryDirectory()];
    // 写入
    [plistStr writeToFile:filePath1             // 写入的文件路径
               atomically:YES                   // 是否保证线程安全
                 encoding:NSUTF8StringEncoding  // 编码格式
                    error:nil];                 // 错误信息
    
    // 数组
    NSArray *plistArr = @[@"one",@"two",@"three"];
    NSString *filePath2 = [NSString stringWithFormat:@"%@/test2.plist", NSTemporaryDirectory()];
    [plistArr writeToFile:filePath2 atomically:YES];

    // 字典
    NSDictionary *pdic = @{@"one":@"1",@"two":@"2",@"three":@"3"};
    NSString *filePath3 = [NSString stringWithFormat:@"%@/test3.plist", NSTemporaryDirectory()];
    [pdic writeToFile:filePath3 atomically:YES];

    // 读取
    NSString *str = [[NSString alloc]initWithContentsOfFile:filePath1 encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"str:%@", str);
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:filePath2];
    NSLog(@"arr:%@", arr);
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:filePath3];
    NSLog(@"dic:%@", dic);
}

// ---------------------------------------------
//log:
//2020-08-17 17:04:39.061649+0800 KKDataStoreDemo[2116:76170] str:Hello World!
//2020-08-17 17:04:39.061871+0800 KKDataStoreDemo[2116:76170] arr:(
//    one,
//    two,
//    three
//)
//2020-08-17 17:04:39.062184+0800 KKDataStoreDemo[2116:76170] dic:{
//    one = 1;
//    three = 3;
//    two = 2;
//}


- (void)userDefaults {
    
    // 写入
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bKey"];
    [[NSUserDefaults standardUserDefaults] setObject:@"test" forKey:@"strKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 读取
    BOOL bValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"bKey"];
    NSLog(@"bValue:%d", (int)bValue);
    NSString *strValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"strKey"];
    NSLog(@"strValue:%@", strValue);
}

// ---------------------------------------------
//log:
//2020-08-17 17:04:39.080255+0800 KKDataStoreDemo[2116:76170] bValue:1
//2020-08-17 17:04:39.080343+0800 KKDataStoreDemo[2116:76170] strValue:test


- (void)keyedArchiver {
    
    Person *person = [Person new];
    person.name = @"小康";
    person.age = 18;
    
    // 存储路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"person1.plist"];
    
    // 归档
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        self.archivedData = [NSKeyedArchiver archivedDataWithRootObject:person requiringSecureCoding:YES error:&error];
        if (self.archivedData == nil || error) {
            NSLog(@"归档失败:%@", error);
            return;
        }
    } else {
        [NSKeyedArchiver archiveRootObject:person toFile:filePath];
    }
    
    // 解档
    Person *pers = nil;
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        pers = [NSKeyedUnarchiver unarchivedObjectOfClass:[Person class] fromData:self.archivedData error:&error];
        if (pers == nil || error) {
            NSLog(@"解档失败:%@", error);
            return;
        }
    } else {
        pers = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    NSLog(@"pers.name:%@, pers.age:%d", pers.name, pers.age);
}

// ---------------------------------------------
//log:
//2020-08-17 17:04:39.081435+0800 KKDataStoreDemo[2116:76170] pers.name:小康, pers.age:18


- (void)bundle {
    
    // 读取
    NSBundle *myBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MyImages" ofType:@"bundle"]];
    NSString *imagePath = [myBundle pathForResource:@"image1" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"image:%@", image);
    
    // 创建
    // 1. MacOS系统下, 新建文件夹, 修改文件名, 后缀.bundle
    // 2. 拖入工程
    // 3. 拖入资源文件至bundle下
}


- (void)keychain {
    
    /**
     Keychain Services 是 macOS 和 iOS 都提供一种安全的存储敏感信息的工具,比如,网络密码:用户访问服务器或者网站,通用密码:用来保存应用程序或者数据库密码.与此同时,用于认证的证书,密钥,和身份信息,也可以存储在Keychain中,Keychain Services 的安全机制保证了存储这些敏感信息不会被窃取。简单说来，Keychain 就是一个安全容器。
     */
    // https://blog.csdn.net/qq_30357519/article/details/85051107
    // https://www.jianshu.com/p/6c2265a82f72
}


// 系统已经包含C标准库stdio.h
- (void)ioFile {
    
    // 如果还没创建目标文件, 创建之
    if (self.filePath.length == 0) {
        
        NSFileManager *manager = [NSFileManager defaultManager];

        // 文件路径
        NSString *TmpDir = NSTemporaryDirectory();
        self.filePath = [NSString stringWithFormat:@"%@%@", TmpDir, @"test/123.avi"];
        
        // 移除之前的filePath
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
        
        // 创建文件夹
        NSString *folderPath = [self.filePath stringByDeletingLastPathComponent];    // 去除最后的组成部分(/123.avi), 剩余.../test
        if(![manager fileExistsAtPath:folderPath]) {
            BOOL success = [manager createDirectoryAtPath:folderPath    //参数1: 创建的目录路径
                              withIntermediateDirectories:YES           //参数2: 是否自动添加缺失的路径
                                               attributes:nil           //参数3: 创建文件的附带信息
                                                    error:nil];         //参数4: 错误信息
            NSLog(@"创建文件夹 success:%@, folderPath:%@", success ? @"YES" : @"NO", folderPath);
        }
        
        // 创建文件 (createFileAtPath:方法不会自动添加缺失的文件夹路径.如本例的test文件夹)
        if(![manager fileExistsAtPath:self.filePath]) {
            BOOL success = [manager createFileAtPath:self.filePath  // 文件路径
                                            contents:nil            // 初始化的内容
                                          attributes:nil];          // 附加信息
            NSLog(@"success:%@, filePath=%@", success ? @"YES" : @"NO", self.filePath);
        }
    }
    
    // 待写入的数据
    NSData *data = [NSData new];
    
    // 1.获取目标文件
    FILE *file = fopen([self.filePath UTF8String], "ab+");    // ab+ 允许读写, 后尾添加数据, 不覆盖原来数据
    // 2.写入文件
    fwrite((char *)data.bytes, data.length, 1, file);
    // 3.关闭文件
    fclose(file);
    
//    fread(<#void *restrict __ptr#>, <#size_t __size#>, <#size_t __nitems#>, <#FILE *restrict __stream#>)
}


- (void)sqlite {
    
    Person *person1 = [Person new];
    person1.name = @"name1";
    person1.age = 1;
    NSString *headStr1 = @"不帅";
    person1.headData = [headStr1 dataUsingEncoding:NSUTF8StringEncoding];
    
    Person *person2 = [Person new];
    person2.name = @"name2";
    person2.age = 2;
    NSString *headStr2 = @"很帅";
    person2.headData = [headStr2 dataUsingEncoding:NSUTF8StringEncoding];
    
    [[DBManager sharedInstance] createDB];
    
    // 添加
    [[DBManager sharedInstance] addPerson:person2 completion:^(BOOL success) {
        NSLog(@"success:%d", (int)success);
    }];

    // 移除
//    [[DBManager sharedInstance] removePerson:person1 completion:^(BOOL success) {
//        NSLog(@"success:%d", (int)success);
//    }];
    
    // 获取
//    [[DBManager sharedInstance] getPersonWithName:@"name2" completion:^(Person * _Nullable person) {
//        NSString *str = [[NSString alloc] initWithData:person.headData encoding:NSUTF8StringEncoding];
//        NSLog(@"name:%@, age:%d, headStr:%@", person.name, person.age, str);
//    }];
    
}


- (void)coreData {
    
    [[CDManager sharedInstance] create];
    [[CDManager sharedInstance] addMan];
//    [[CDManager sharedInstance] deleteMan];
//    [[CDManager sharedInstance] updateMan];
//    [[CDManager sharedInstance] readMan];
}


@end
