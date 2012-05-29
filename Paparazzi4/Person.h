//
//  Person.h
//  Paparazzi4
//
//  Created by  on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Person : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * recordID;
@property (nonatomic, strong) NSString * recordName;
@property (nonatomic, strong) NSSet *photos;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
