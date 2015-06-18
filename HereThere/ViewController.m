//
//  ViewController.m
//  HereThere
//
//  Created by Chad Ackerman on 6/14/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import "ViewController.h"
static NSString * const kWUKey = @"c025f7ff8ce9826d";
static NSString * const kOWMKey = @"f45984d7c8c7ac05bd9fa14d6383f489";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //graph points array
    self.graphPoints = [NSMutableArray new];
    
    //chart attributes and style
    self.chartCurrentWeatherHourly.alwaysDisplayDots = YES;
    self.chartCurrentWeatherHourly.animationGraphStyle = BEMLineAnimationFade;
    self.chartCurrentWeatherHourly.enableTouchReport = YES;
    self.chartCurrentWeatherHourly.enablePopUpReport = YES;
    self.chartCurrentWeatherHourly.colorBackgroundPopUplabel = [UIColor clearColor];
    
    [self getCurrentLocation];
}

-(void)getCurrentLocation {
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

-(void)returnCurrentWeatherForCurrentLocation:(CLLocation *)currentLocation {
    CZWundergroundRequest *request = [CZWundergroundRequest newConditionsRequest];
    CZWundergroundRequest *forecastRequest = [CZWundergroundRequest newHourlyRequest];
    
    NSDate *currentTimedate = [NSDate date];
    NSDate *prevTimedate = [currentTimedate dateByAddingTimeInterval:-3*60*60];
    NSLog(@"prev date: %@", prevTimedate);
//    CZWundergroundRequest *historicalRequest = [CZWundergroundRequest newHistoryRequestForDate:prevTimedate];
    
    request.location = [CZWeatherLocation locationFromLocation:currentLocation];
    forecastRequest.location = [CZWeatherLocation locationFromLocation:currentLocation];
    request.key = kWUKey;
    forecastRequest.key = kWUKey;
    
    [request sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        CZWeatherCurrentCondition *condition = data.current;
        
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
    
//    [historicalRequest sendWithCompletion:^(CZWeatherData *data, NSError *error){
//        if (!error) {
//            for (int i = 0; i < 4; i++) {
//                CZWeatherHourlyCondition *h = [data.hourlyForecasts objectAtIndex:i];
//                [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
//                
//                NSLog(@"Historical Temp: %.f, Date: %@", h.temperature.f, h.date);
//            }
//            
//            [forecastRequest sendWithCompletion:^(CZWeatherData *data, NSError *error) {
//                if (!error) {
//                    // Fast enumeration for all 36 data points
//                    //        for (CZWeatherHourlyCondition *h in data.hourlyForecasts) {
//                    //            NSLog(@"%.f", h.temperature.f);
//                    //            [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
//                    //        }
//                    
//                    //For the first 12 items of hourly forcast, add to the array.
//                    for (int i = 0; i < 8; i++) {
//                        CZWeatherHourlyCondition *h = [data.hourlyForecasts objectAtIndex:i];
//                        [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
//                        
//                        NSLog(@"Temp: %.f, Date: %@", h.temperature.f, h.date);
//                    }
//                    
//                    [self.chartCurrentWeatherHourly reloadGraph];
//                } else {
//                    NSLog(@"Error: %@", error.description);
//                }
//                
//            }];
//        } else {
//            NSLog(@"Error: %@", error.description);
//        }
//        
//    }];
    
    [forecastRequest sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        if (!error) {
            [self.graphPoints removeAllObjects];
            // Fast enumeration for all 36 data points
            //        for (CZWeatherHourlyCondition *h in data.hourlyForecasts) {
            //            NSLog(@"%.f", h.temperature.f);
            //            [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
            //        }
            
            //For the first 12 items of hourly forcast, add to the array.
            for (int i = 0; i < 12; i++) {
                CZWeatherHourlyCondition *h = [data.hourlyForecasts objectAtIndex:i];
                [self.graphPoints addObject:[NSNumber numberWithFloat:h.temperature.f]];
                
                NSLog(@"Temp: %.f, Date: %@", h.temperature.f, h.date);
            }
            
            [self.chartCurrentWeatherHourly reloadGraph];
        } else {
            NSLog(@"Error: %@", error.description);
        }
        
    }];
    
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.graphPoints count]; // Number of points in the graph.
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.graphPoints objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
}

-(void)unwindFromLocationSearchController:(UIStoryboardSegue *)segue {
    LocationSearchTableViewController *searchVC = (LocationSearchTableViewController *) segue.sourceViewController;
    NSLog(@"Newly selected city: %@", searchVC.seletedCityResult);
    
    [[LMGeocoder sharedInstance] geocodeAddressString:searchVC.seletedCityResult
                                              service:kLMGeocoderGoogleService
                                    completionHandler:^(LMAddress *address, NSError *error) {
                                        if (address && !error) {
                                            CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:address.coordinate.latitude longitude:address.coordinate.longitude];
                                            [self returnCurrentWeatherForCurrentLocation:newLocation];
                                        }
                                        else {
                                            NSLog(@"Error: %@", error.description);
                                        }
                                    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshWeatherData:(id)sender {
    [self getCurrentLocation];
}
@end
