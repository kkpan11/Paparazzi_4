//
//  ImageToDataTransformer.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageToDataTransformer : NSValueTransformer
{
    
}

+ (BOOL)allowsReverseTransformation;
+ (Class)transformedValueClass;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;

@end
