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
    
    //If any compared locations exist, load the first one.
    NSArray *compareLocations = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"]];
    if (compareLocations.count > 0) {
        NSNumber *lat = [[compareLocations firstObject] valueForKey:@"lat"];
        NSNumber *lng = [[compareLocations firstObject] valueForKey:@"lng"];
        
        CLLocationDegrees latitude = [lat floatValue];
        CLLocationDegrees longitude = [lng floatValue];
        
        CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self returnWeatherForLocation:aLocation forCurrentView:NO];
    }
    
    //graph points array
    self.currLocHourlyData = [NSMutableArray new];
    self.compLocHourlyData = [NSMutableArray new];
    
    //chart attributes and style
    self.chartCurrentWeatherHourly.alwaysDisplayDots = YES;
    self.chartCurrentWeatherHourly.animationGraphStyle = BEMLineAnimationFade;
    self.chartCurrentWeatherHourly.enableTouchReport = YES;
    self.chartCurrentWeatherHourly.enablePopUpReport = YES;
    self.chartCurrentWeatherHourly.colorBackgroundPopUplabel = [UIColor clearColor];
    
    self.chartComparedWeatherHourly.alwaysDisplayDots = YES;
    self.chartComparedWeatherHourly.animationGraphStyle = BEMLineAnimationFade;
    self.chartComparedWeatherHourly.enableTouchReport = YES;
    self.chartComparedWeatherHourly.enablePopUpReport = YES;
    self.chartComparedWeatherHourly.colorBackgroundPopUplabel = [UIColor clearColor];
    
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
                                                 [self returnWeatherForLocation:currentLocation forCurrentView:YES];
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

-(void)returnWeatherForLocation:(CLLocation *)location forCurrentView:(BOOL)current {
    CZWundergroundRequest *request = [CZWundergroundRequest newConditionsRequest];
    CZWundergroundRequest *forecastRequest = [CZWundergroundRequest newHourlyRequest];
    WeatherData *weather = [WeatherData new];
    
//    NSDate *currentTimedate = [NSDate date];
//    NSDate *prevTimedate = [currentTimedate dateByAddingTimeInterval:-3*60*60];
//    CZWundergroundRequest *historicalRequest = [CZWundergroundRequest newHistoryRequestForDate:prevTimedate];
    
    request.location = [CZWeatherLocation locationFromLocation:location];
    forecastRequest.location = [CZWeatherLocation locationFromLocation:location];
    request.key = kWUKey;
    forecastRequest.key = kWUKey;
    
    [request sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        CZWeatherCurrentCondition *condition = data.current;
        weather.currTemp = condition.temperature.f;
        
        [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:location.coordinate
                                                      service:kLMGeocoderGoogleService
                                            completionHandler:^(LMAddress *address, NSError *error) {
                                                if (address && !error) {
                                                    weather.city = address.locality;
                                                    weather.state = address.administrativeArea;
                                                    
                                                    [self updateViewWithWeather:weather forCurrentView:current];
                                                }
                                                else {
                                                    NSLog(@"Error: %@", error.description);
                                                }
                                            }];
    }];
    
    
    [forecastRequest sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        if (!error) {
            //For the first 12 items of hourly forcast, add to the array.
            NSMutableArray *hourly = [NSMutableArray new];
            for (int i = 0; i < 12; i++) {
                CZWeatherHourlyCondition *h = [data.hourlyForecasts objectAtIndex:i];
                [hourly addObject:[NSNumber numberWithFloat:h.temperature.f]];
            }
            weather.twelveHourData = [NSArray arrayWithArray:hourly];
            [self updateChartsWithData:weather forCurrentView:current];

        } else {
            NSLog(@"Error: %@", error.description);
        }
        
    }];
    
}


//Update view with new weather data from block. Check if it is the comparison view or the current view.
- (void)updateViewWithWeather:(WeatherData *)data forCurrentView:(BOOL)current {
    if (current == YES) {
        self.lblCurrentLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", data.currTemp];
        self.lblCurrentLocationCityState.text = [NSString stringWithFormat:@"%@, %@", data.city, data.state];
    } else {
        self.lblComparedWeatherLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", data.currTemp];
        self.lblComparedLocationCityState.text = [NSString stringWithFormat:@"%@, %@", data.city, data.state];
    }
}

- (void)updateChartsWithData:(WeatherData *)data forCurrentView:(BOOL)current {
    if (current == YES) {
        self.currLocHourlyData = [data.twelveHourData mutableCopy];
        [self.chartCurrentWeatherHourly reloadGraph];
    } else {
        self.compLocHourlyData = [data.twelveHourData mutableCopy];
        [self.chartComparedWeatherHourly reloadGraph];
    }
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    if (graph == self.chartCurrentWeatherHourly) {
        return [self.currLocHourlyData count]; // Number of points in the graph.
    } else {
        return [self.compLocHourlyData count]; // Number of points in the graph.
    }
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if (graph == self.chartCurrentWeatherHourly) {
        return [[self.currLocHourlyData objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
    } else {
        return [[self.compLocHourlyData objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
    }
}

-(void)unwindFromLocationSearchController:(UIStoryboardSegue *)segue {
    LocationSearchTableViewController *searchVC = (LocationSearchTableViewController *) segue.sourceViewController;
    NSLog(@"Newly selected city: %@", searchVC.selectedLocation);
    
    //New location from dictonary.
    [self newLocationFromLat:[searchVC.selectedLocation copy]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshWeatherData:(id)sender {
    
}

//When a user swipes the paging view this function will be called to switch between location items.
- (IBAction)changeLocation:(id)sender {
    
}

//When a location is added a new view is added to the scroll view with paging enabled.
-(void)newLocationFromLat:(NSDictionary *)location {
    //Variables
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *locationsKey = @"savedLocations";
    
    //If the array is yet to be stored, create it.
    if (![d arrayForKey:locationsKey]) {
        //TODO: check for duplicates.////////////////////////////////////////////////////////
        NSMutableArray *newLocations = [[NSMutableArray alloc] initWithObjects:location, nil];
        [d setObject:newLocations forKey:locationsKey];
        NSLog(@"I added the array, you should only see this once");
        
        NSLog(@"Locations from first time: %@", [d objectForKey:locationsKey]);
    }
    //If it exists add to it
    else {
        //Add new location object CLLocation.
        //TODO: check for duplicates.////////////////////////////////////////////////////////
        NSMutableArray *retrieved = [[d arrayForKey:locationsKey] mutableCopy];
        [retrieved addObject:location];
        [d setObject:retrieved forKey:locationsKey];
        NSLog(@"Locations from after the first time: %@", [d objectForKey:locationsKey]);
    }
    
    [self.tableSavedLocations reloadData];
}

//Set up tableview for saved locations
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"savedLocation"];
    
    NSArray *l = [[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [[l objectAtIndex:indexPath.row] valueForKey:@"city"], [[l objectAtIndex:indexPath.row] valueForKey:@"state"]];
    
    return cell;
}

@end
