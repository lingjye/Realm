//
//  Dog.h
//  Realm
//
//  Created by txooo on 2017/12/15.
//  Copyright © 2017年 txooo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Dog : RLMObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *color;
@end

RLM_ARRAY_TYPE(Dog)
