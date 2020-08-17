
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


// 设备连接状态
typedef NS_ENUM(NSInteger, KKDeviceConnectStatus) {
    KKDeviceConnectStatus_Offline,              // 断线
    KKDeviceConnectStatus_Connecting,           // 连线中
    KKDeviceConnectStatus_Connected,            // 连线成功
    KKDeviceConnectStatus_Online,               // 在线 (登录成功)
    KKDeviceConnectStatus_InvalidPassword,      // 无效密码
    KKDeviceConnectStatus_InvalidSecurityCode,  // 无效安全码 (设备已重置)
};

// 设备分辨率
typedef NS_ENUM(NSInteger, KKDeviceResolution) {
    KKDeviceResolution_Low,
    KKDeviceResolution_Mid,
    KKDeviceResolution_High
};

// 数据流类型
typedef NS_ENUM(NSInteger, KKStreamType) {
    KKStreamType_live,      // 直播
    KKStreamType_playback,  // 回放
};

// 红外灯状态
typedef NS_ENUM(NSInteger, KKDeviceInfraredStatus) {
    KKDeviceInfraredStatus_Open,
    KKDeviceInfraredStatus_Close,
    KKDeviceInfraredStatus_Auto,
};

// SD卡状态
typedef NS_ENUM(NSInteger, KKSDStatus) {
    KKSDStatus_No,          // 无卡
    KKSDStatus_Valid,       // 有效
    KKSDStatus_Nonsupport,  // 格式不支持, 需格式化
};


@interface KKDevice : NSObject

@property (nonatomic, copy)     NSString    *did;           // 设备ID
@property (nonatomic, copy)     NSString    *name;          // 名称
@property (nonatomic, copy)     NSString    *pwd;           // 密码
@property (nonatomic, copy)     NSString    *securityCode;  // 设备安全码 (设备每复位后刷新)
@property (nonatomic, assign)   BOOL        imageFlip;      // 图像翻转
@property (nonatomic, assign)   BOOL        imageMirror;    // 图像镜像
@property (nonatomic, assign)   BOOL        infraredOn;     // 红外开关 (废弃, 使用infraredStatus)
@property (nonatomic, assign)   BOOL        indicatorOn;    // 指示灯
@property (nonatomic, assign)   BOOL        beShared;       // 是否被分享
@property (nonatomic, assign)   BOOL        serverExist;    // 服务器是否存在
@property (nonatomic, strong)   NSData      *previewData;   // 预览图
@property (nonatomic, strong)   NSArray     *localIDs;      // 保存到相册的图片/视频id

@end


NS_ASSUME_NONNULL_END
