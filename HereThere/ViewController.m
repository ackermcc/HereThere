//
//  ViewController.m
//  HereThere
//
//  Created by Chad Ackerman on 6/14/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import "ViewController.h"
static NSString * const kWUKey = @"c025f7ff8ce9826d";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 [self returnCurrentWeatherForCurrentLocation:currentLocation];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                 
                                                 NSLog(@"Timed out, get better interwebs dude");
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                                 NSLog(@"Error: %ld", (long)status);
                                             }
                                         }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.graphPoints = [NSMutableArray new];
}

-(void)returnCurrentWeatherForCurrentLocation:(CLLocation *)currentLocation {
    CZWundergroundRequest *request = [CZWundergroundRequest newConditionsRequest];
    CZWundergroundRequest *forecastRequest = [CZWundergroundRequest newHourlyRequest];
    
    request.location = [CZWeatherLocation locationFromLocation:currentLocation];
    forecastRequest.location = [CZWeatherLocation locationFromLocation:currentLocation];
    request.key = kWUKey;
    forecastRequest.key = kWUKey;
    
    [request sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        CZWeatherCurrentCondition *condition = data.current;
        
        //NSArray *currentHourlyForecast = [[NSArray alloc] initWithArray:data.hourlyForecasts];
        
        [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:currentLocation.coordinate
                                                      service:kLMGeocoderGoogleService
                                            completionHandler:^(LMAddress *address, NSError *error) {
                                                if (address && !error) {
                                                    self.lblCurrentLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", condition.temperature.f];
                                                    self.lblCurrentLocationCityState.text = [NSString stringWithFormat:@"%@, %@", address.locality, address.administrativeArea];
                                                }
                                                else {
                                                    NSLog(@"Error: %@", error.description);
                                                }
                                            }];
    }];
    
    [forecastRequest sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        NSLog(@"%@",[data.hourlyForecasts firstObject]);
        for (CZWeatherHourlyCondition *h in data.hourlyForecasts) {
            NSLog(@"%.f", h.temperature.f);
            [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
        }
        [self.viewLineGraph reloadGraph];
    }];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.graphPoints count]; // Number of points in the graph.
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.graphPoints objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
