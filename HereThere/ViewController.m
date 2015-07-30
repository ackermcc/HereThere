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
    
    //Set up JBChart view
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(0, (self.view.frame.size.height/2) - (self.view.frame.size.height/5) + 11, self.view.frame.size.width, self.view.frame.size.height/5);
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    [self.view addSubview:self.lineChartView];
    
    //If any compared locations exist, load the first one on the list.
    NSArray *compareLocations = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"]];
    if (compareLocations.count > 0) {
        NSNumber *lat = [[compareLocations firstObject] valueForKey:@"lat"];
        NSNumber *lng = [[compareLocations firstObject] valueForKey:@"lng"];
        
        CLLocationDegrees latitude = [lat floatValue];
        CLLocationDegrees longitude = [lng floatValue];
        
        CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        NSLog(@"I made it here with %@", aLocation);
        [self returnWeatherForLocation:aLocation forCurrentView:NO];
    }
    
    //Set up arrays for collecting historical weather data.
    self.currLocHourlyData = [NSMutableArray new];
    self.compLocHourlyData = [NSMutableArray new];
    self.allHourlyData = [NSMutableDictionary new];
    
    //TODO: Set custom chart attributes and style.
    
    
    //Get current location and update view.
    [self getCurrentLocation];
//    [self.tableSavedLocations reloadData];
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
    CZWundergroundRequest *forecastRequest = [CZWundergroundRequest newHourlyRequest];
    WeatherData *weather = [WeatherData new];
    
    forecastRequest.location = [CZWeatherLocation locationFromLocation:location];
    forecastRequest.key = kWUKey;
    
    
    [forecastRequest sendWithCompletion:^(CZWeatherData *data, NSError *error) {
        if (!error) {
//            NSLog(@"What is a placemark: %@, %@", data.placemark.locality, data.placemark.administrativeArea);
            //Update view with city and state information
            weather.city = data.placemark.locality;
            weather.state = data.placemark.administrativeArea;
            
            //For the first 12 items of hourly forcast, add to the array.
            NSMutableArray *hourly = [NSMutableArray new];
            for (int i = 0; i < 12; i++) {
                CZWeatherHourlyCondition *h = [data.hourlyForecasts objectAtIndex:i];
                [hourly addObject:[NSNumber numberWithFloat:h.temperature.f]];
                
                //Set the current temperature for the first object
                if (i==0) {
                    weather.currTemp = h.temperature.f;
                }
            }
            weather.twelveHourData = [NSArray arrayWithArray:hourly];
            
            //Update the view with appropriate data.
            [self updateChartWithData:weather forCurrentView:current];
            [self updateViewWithWeather:weather forCurrentView:current];

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

//Add new weather data to allHourlyData dictionary and reload the chart.
- (void)updateChartWithData:(WeatherData *)data forCurrentView:(BOOL)current {
    if (current) {
        self.currLocHourlyData = [data.twelveHourData mutableCopy];
        [self.allHourlyData setObject:self.currLocHourlyData forKey:@"currentHourlyData"];
    } else {
        self.compLocHourlyData = [data.twelveHourData mutableCopy];
        [self.allHourlyData setObject:self.compLocHourlyData forKey:@"comparedHourlyData"];
    }
    
    [self.lineChartView reloadData];
}

//JBChart delegate methods.

- (void)dealloc
{
    self.lineChartView.delegate = nil;
    self.lineChartView.dataSource = nil;
}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.allHourlyData count]; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return 12; // Number of points in the graph.
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    //Load historical data based on line index.
    if (lineIndex == 1) {
        if ([self.allHourlyData objectForKey:@"currentHourlyData"]) {
            NSLog(@"Line 1: current");
            return [[self.currLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        } else {
            NSLog(@"Line 1: compared");
            return [[self.compLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        }
    } else {
        if ([self.allHourlyData objectForKey:@"comparedHourlyData"]) {
            NSLog(@"Line 2: compared");
            return [[self.compLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        } else {
            NSLog(@"Line 2: current");
            return [[self.currLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        }
    }
    return 0;
}

//- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
//    if (graph == self.chartCurrentWeatherHourly) {
//        return [self.currLocHourlyData count]; // Number of points in the graph.
//    } else {
//        return [self.compLocHourlyData count]; // Number of points in the graph.
//    }
//}
//
//- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
//    if (graph == self.chartCurrentWeatherHourly) {
//        return [[self.currLocHourlyData objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
//    } else {
//        return [[self.compLocHourlyData objectAtIndex:index] floatValue]; // The value of the point on the Y-Axis for the index.
//    }
//}

-(void)unwindFromLocationSearchController:(UIStoryboardSegue *)segue {
    LocationSearchTableViewController *searchVC = (LocationSearchTableViewController *) segue.sourceViewController;
    NSLog(@"Newly selected city: %@", searchVC.selectedLocation);
    
    //New location from dictonary.
    [self newLocationFromLat:[searchVC.selectedLocation copy]];

}

-(void)unwindFromSavedLocations:(UIStoryboardSegue *)segue {
    SavedLocationsTableViewController *savecVC = (SavedLocationsTableViewController *) segue.sourceViewController;
    
    [self returnWeatherForLocation:savecVC.selectedLocation forCurrentView:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshWeatherData:(id)sender {
    
}

//When the user selectes to change, slide the compared weather view down and show the tableview for selection.
- (IBAction)changeLocation:(id)sender {
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.viewComparedWeather.frame = CGRectMake(self.viewComparedWeather.frame.origin.x, self.viewComparedWeather.frame.origin.y * 2, self.viewComparedWeather.frame.size.width, self.viewComparedWeather.frame.size.height);
//    } completion:^(BOOL complete){
//        
//    }];
}

//When a location is added a new view is added.
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
    NSNumber *lat = [[[d arrayForKey:locationsKey] lastObject] valueForKey:@"lat"];
    NSNumber *lng = [[[d arrayForKey:locationsKey] lastObject] valueForKey:@"lng"];
    
    CLLocationDegrees latitude = [lat floatValue];
    CLLocationDegrees longitude = [lng floatValue];
    
    CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self returnWeatherForLocation:aLocation forCurrentView:NO];
}

//Set up tableview for saved locations
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"] count];
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"savedLocation"];
//    
//    NSArray *l = [[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [[l objectAtIndex:indexPath.row] valueForKey:@"city"], [[l objectAtIndex:indexPath.row] valueForKey:@"state"]];
//    
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *l = [[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"];
//    NSNumber *lat = [[l objectAtIndex:indexPath.row] valueForKey:@"lat"];
//    NSNumber *lng = [[l objectAtIndex:indexPath.row] valueForKey:@"lng"];
//    
//    CLLocationDegrees latitude = [lat floatValue];
//    CLLocationDegrees longitude = [lng floatValue];
//    
//    CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
//    [self returnWeatherForLocation:aLocation forCurrentView:NO];
//    
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.viewComparedWeather.frame = CGRectMake(self.viewComparedWeather.frame.origin.x, self.viewComparedWeather.frame.origin.y / 2, self.viewComparedWeather.frame.size.width, self.viewComparedWeather.frame.size.height);
//    } completion:^(BOOL complete){
//        [self.tableSavedLocations deselectRowAtIndexPath:indexPath animated:YES];
//    }];
//}

@end
