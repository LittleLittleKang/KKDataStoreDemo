//
//  Person.m
//  KKDataStoreDemo
//
//  Created by 看影成痴 on 2020/8/13.
//  Copyright © 2020 看影成痴. All rights reserved.
//

#import "Person.h"

@implementation Person

// 是否支持加密编码
+ (BOOL)supportsSecureCoding {
    
    return YES;
}

// 归档
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInt:self.age forKey:@"age"];
    [aCoder encodeObject:self.headData forKey:@"headData"];
}

// 解档
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeIntForKey:@"age"];
        self.headData = [aDecoder decodeObjectForKey:@"headData"];
    }
    return self;
}

@end
