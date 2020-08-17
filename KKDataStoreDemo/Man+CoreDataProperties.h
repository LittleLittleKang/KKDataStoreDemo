//
//  Man+CoreDataProperties.h
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/17.
//  Copyright © 2020 看影成痴. All rights reserved.
//
//

#import "Man+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Man (CoreDataProperties)

+ (NSFetchRequest<Man *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t age;
@property (nullable, nonatomic, retain) NSData *headData;

@end

NS_ASSUME_NONNULL_END
