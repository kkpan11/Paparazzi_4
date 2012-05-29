//
//  Photo.h
//  Paparazzi4
//
//  Created by  on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ImageToDataTransformer.h"

@class Person;

@interface Photo : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) id image;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) Person *person;

@end
