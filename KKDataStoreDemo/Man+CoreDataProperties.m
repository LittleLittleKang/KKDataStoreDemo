//
//  Man+CoreDataProperties.m
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/17.
//  Copyright © 2020 看影成痴. All rights reserved.
//
//

#import "Man+CoreDataProperties.h"

@implementation Man (CoreDataProperties)

+ (NSFetchRequest<Man *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Man"];
}

@dynamic name;
@dynamic age;
@dynamic headData;

@end
