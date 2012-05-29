//
//  MapViewController.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    MKMapView *globeMapView;
    NSMutableArray *mapAnnotations;
}

@property (nonatomic, weak) NSArray *photos;

- (void)reloadAnnotations;

@end
