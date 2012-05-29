//
//  PhotoAnnotation.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Photo;

@interface PhotoAnnotation : NSObject <MKAnnotation>
{
    
}
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) Photo *photo;

- (id)initWithPhoto:(Photo *)photo;

@end
