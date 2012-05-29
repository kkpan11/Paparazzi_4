//
//  PhotoAnnotation.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoAnnotation.h"
#import "Photo.h"
#import "Person.h"

@implementation PhotoAnnotation

@synthesize photo = _photo;


- (id)initWithPhoto:(Photo *)photo
{
    self = [super init];
    if (self) {
        self.photo = photo;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.photo.latitude doubleValue];
    theCoordinate.longitude = [self.photo.longitude doubleValue];
    return theCoordinate; 
}

- (NSString *)title
{
    return ![self.photo.name isEqualToString:@""] ? self.photo.name : @"No photo title.";
}

// optional
- (NSString *)subtitle
{
    return ![self.photo.name isEqualToString:@""] ? self.photo.name : @"No person name.";
}

@end
