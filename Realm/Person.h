//
//  Person.h
//  Realm
//
//  Created by txooo on 2017/12/15.
//  Copyright © 2017年 txooo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Dog.h"

@interface Person : RLMObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic, strong) Company *company;

@property (nonatomic, strong) RLMArray <Dog *><Dog> *dogs;

@end
