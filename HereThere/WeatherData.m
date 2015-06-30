//
//  WeatherData.m
//  HereThere
//
//  Created by Chad Ackerman on 6/29/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import "WeatherData.h"

static NSString * const kWUKey = @"c025f7ff8ce9826d";
static NSString * const kOWMKey = @"f45984d7c8c7ac05bd9fa14d6383f489";

@interface WeatherData()

@end

@implementation WeatherData

-(id)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (self) {
        CZWundergroundRequest *request = [CZWundergroundRequest newConditionsRequest];
        CZWundergroundRequest *forecastRequest = [CZWundergroundRequest newHourlyRequest];
        
        request.location = [CZWeatherLocation locationFromLocation:location];
        forecastRequest.location = [CZWeatherLocation locationFromLocation:location];
        request.key = kWUKey;
        forecastRequest.key = kWUKey;
        
        [request sendWithCompletion:^(CZWeatherData *data, NSError *error) {
            CZWeatherCurrentCondition *condition = data.current;
            
            _currTemp = condition.temperature.f;
            NSLog(@"Im here with temp: %.f", condition.temperature.f);
            
            [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:location.coordinate
                                                          service:kLMGeocoderGoogleService
                                                completionHandler:^(LMAddress *address, NSError *error) {
                                                    if (address && !error) {
                                                        _city = address.locality;
                                                        _state = address.administrativeArea;
                                                        NSLog(@"Here w/ Location: %@, %@", _city, _state);
                                                    }
                                                    else {
                                                        NSLog(@"Error: %@", error.description);
                                                    }
                                                }];
        }];
    }
    
    return self;
}

-(id)initWithLat:(float)lat andLong:(float)lng {
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    latitude = lat;
    longitude = lng;
    
    CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return [self initWithLocation:aLocation];
}

@end
