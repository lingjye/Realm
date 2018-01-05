//
//  ViewController.m
//  Realm
//
//  Created by txooo on 2017/12/15.
//  Copyright © 2017年 txooo. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <Realm/Realm.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array = @[@"增",@"删",@"改",@"查",@"排序",@"大量读取"];
    NSArray *selectors = @[@"insert",@"delete",@"update",@"select",@"sort",@"multithreadRealm"];
    [self config];
    NSLog(@"db path:%@", [RLMRealm defaultRealm].configuration.fileURL);
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:array[i] forState:UIControlStateNormal];
        button.frame = CGRectMake(100, 100 + 50 * i, 100, 40);
        [button setBackgroundColor:[UIColor yellowColor]];
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.view addSubview:button];
        SEL selector = NSSelectorFromString(selectors[i]);
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)config {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs = @[
                                        config.fileURL,
                                        [config.fileURL URLByAppendingPathExtension:@"lock"],
                                        [config.fileURL URLByAppendingPathExtension:@"management"],
                                        ];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSURL *URL in realmFileURLs) {
        NSError *error = nil;
        [manager removeItemAtURL:URL error:&error];
        if (error) {
            NSLog(@"clean realm error:%@", error);
        }
    }
    NSLog(@"%@",realmFileURLs);
}

- (void)insert {
    NSLog(@"增");
    Person *me = [[Person alloc] init];
    me.name = @"crylown";
    me.age = 12;
    
    Dog *myDog = [[Dog alloc] init];
    myDog.name = @"myDog";
    myDog.color = @"red";
    
    Dog *yourDog = [[Dog alloc] init];
    yourDog.name = @"yourDog";
    yourDog.color = @"green";
    
    [me.dogs addObject:myDog];
    [me.dogs addObject:yourDog];
    
    Company *company = [[Company alloc] init];
    company.name = @"Company";
    company.age = 10;
    
    me.company = company;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        // 进行数据处理
        [realm addObject:me];
    }];
}

- (void)delete {
    NSLog(@"删");
    //删除某个在Realm数据库中的数据。
    //Book *cheeseBook = ... 存储在 Realm 中的 Book 对象
    // 在事务中删除一个对象
//    [realm beginWriteTransaction];
//    [realm deleteObject:cheeseBook];
//    [realm commitWriteTransaction];

    //删除所有数据
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
    
}

- (void)update {
    NSLog(@"改");
    //根据主键更新 创建一个带有主键的“书籍”对象，作为事先存储的书籍
//    Person *me = ;
//    me.name = @"crylown";
//    me.age = 13;
//
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    [realm transactionWithBlock:^{
//        // 通过 id = 1 更新该书籍
//        [Person createOrUpdateInRealm:realm withValue:me];
//    }];
    
    //键值编码
    RLMResults *persons = [Person allObjects];
    
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[persons firstObject] setValue:@15 forKeyPath:@"age"];
        // 将每个人的 name 属性设置为“地球”
        [persons setValue:@"地球" forKeyPath:@"name"];
    }];
    NSLog(@"%@---",persons);
}

- (void)select {
    NSLog(@"查");
    // 查询默认的 Realm 数据库
    RLMResults *dogs = [Dog allObjects]; // 从默认的 Realm 数据库中，检索所有狗狗
    // 查询指定的 Realm 数据库
//    NSURL *url = [NSURL fileURLWithPath:@"pets.realm"];
//    RLMRealm *petsRealm = [RLMRealm realmWithURL:url]; // 获得一个指定的 Realm 数据库
//    RLMResults *otherDogs = [Dog allObjectsInRealm:petsRealm]; // 从该 Realm 数据库中，检索所有狗狗
    //条件查询
    //1.使用断言字符串查询:
//    RLMResults *tanDogs = [Dog objectsWhere:@"color = '棕黄色' AND name BEGINSWITH '大'"];
    //2. 使用 NSPredicate 查询
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"color = %@ AND name BEGINSWITH %@",
//                         @"棕黄色", @"大"];
//    RLMResults *tanDogs = [Dog objectsWithPredicate:pred];
    //3.链式查询
    RLMResults *persons = [Person objectsWhere:@"name = 'crylown'"];
//    RLMResults *tanDogsWithBNames = [tanDogs objectsWhere:@"name BEGINSWITH '大'"];
    
    NSLog(@"%@---%@",dogs,persons);
}

-(void)multithreadRealm {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        NSLog(@"start async");
        RLMResults *results = [Person objectsWhere:@"name = '张三' "];
        if (results.count > 0) {
            Person *person = results[0];
            NSLog(@"outer block, name:%@", person.name);
        }
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            NSLog(@"in async block");
            RLMResults *results = [Person objectsWhere:@"name = '张三' "];
            if (results.count > 0) {
                Person *person = results[0];
                person.name = @"王麻子";
                NSLog(@"change name to wangmazi");
            }
        }];
        if (results.count > 0) {
            Person *person = results[0];
            NSLog(@"async person:%@, tid=%@", person.name, [NSThread currentThread]);
        }
    });
    
    NSArray *names = @[@"张三", @"李四"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        int i = 0;
        while (i < 2) {
            NSString *name = names[i];
            RLMResults *results = [Person objectsWhere:@"name = %@", name];
            if (results.count > 0) {
                Person *person = results[0];
                if ([person.name isEqualToString:@"李四"]) {
                    person.name = @"王五";
                    NSLog(@"change name to wangwu");
                } else {
                    person.name = @"李四";
                    NSLog(@"change name to lisi");
                }
                sleep(3);
            }
            i++;
        }
    }];
}

//排序
- (void)sort {
    // 排序名字以“大”开头的棕黄色狗狗
    RLMResults *sortedDogs = [[Dog allObjects] sortedResultsUsingKeyPath:@"name" ascending:NO];
    NSLog(@"%@",sortedDogs);
}
//迁移
- (void)migrateRealm {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion){
        if (oldSchemaVersion < 1) {
            //新增属性
            [migration enumerateObjects:Person.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      
//                                      // 设置新增属性的值
//                                      newObject[@"fullName"] = [NSString stringWithFormat:@"%@ %@",
//                                                                oldObject[@"firstName"],
//                                                                oldObject[@"lastName"]];
                                  }];
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
