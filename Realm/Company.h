//
//  Company.h
//  Realm
//
//  Created by txooo on 2017/12/15.
//  Copyright © 2017年 txooo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Company : RLMObject
@property (nonatomic, strong) NSString *name;

@property (nonatomic) NSInteger age;
@end
