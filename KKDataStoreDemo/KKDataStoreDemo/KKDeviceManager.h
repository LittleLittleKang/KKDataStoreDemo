
#import <Foundation/Foundation.h>
#import "KKDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface KKDeviceManager : NSObject


+ (instancetype)sharedInstance;


/**
 添加单个设备 (已存在设备则先删除后插入)

 @param device 设备
 @param block YES:成功 NO:失败
 */
- (void)addDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block;


/**
 移除单个设备

 @param device 设备
 @param block YES:成功 NO:失败
 */
- (void)removeDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block;


/**
 移除所有设备

 @param block YES:成功 NO:失败
 */
- (void)removeAllDeviceFinishBlock:(nullable void (^) (BOOL success))block;


/**
 更新设备信息 (有设备才会更新)

 @param device 设备
 @param block YES:成功 NO:失败
 */
- (void)updateDevice:(KKDevice *)device finishBlock:(nullable void (^) (BOOL success))block;


/// 获取设备列表
/// @param block 设备列表
- (void)getDeviceListFinishBlock:(nullable void (^) (NSMutableArray<KKDevice *> *deviceList))block;


@end

NS_ASSUME_NONNULL_END
