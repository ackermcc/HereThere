//
//  WeatherData.h
//  HereThere
//
//  Created by Chad Ackerman on 6/29/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CZWeatherKit.h"
#import "LMGeocoder.h"

@interface WeatherData : NSObject

@property (copy) NSString *city;
@property (copy) NSString *state;
@property float currTemp;
@property (copy) NSArray *twelveHourData;

-(id)init;

@end
