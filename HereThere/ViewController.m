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
    
    //Background view color
    self.view.backgroundColor = [UIColor htw_duskBlueColor];
    
    //Set up JBChart view
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(0.0, self.view.frame.size.height-(self.view.frame.size.height/3)-100.0, self.view.frame.size.width, self.view.frame.size.height/3);
    
    //Add time labels
    self.lblCurrTime = [UILabel new];
    self.lblCurrTime.text = @"";
    self.lblCurrTime.font = [UIFont systemFontOfSize:15.0 weight:0.0];
    self.lblCurrTime.textAlignment = NSTextAlignmentRight;
    [self.lblCurrTime sizeToFit];
    [self.lineChartView addSubview:self.lblCurrTime];
    
    self.lblCompTime = [UILabel new];
    self.lblCompTime.text = @"";
    self.lblCompTime.font = [UIFont systemFontOfSize:15.0 weight:0.0];
    self.lblCurrTime.textAlignment = NSTextAlignmentLeft;
    [self.lblCompTime sizeToFit];
    [self.lineChartView addSubview:self.lblCompTime];
    
    self.lblCompTime.hidden = true;
    self.lblCurrTime.hidden = true;
    
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    self.lineChartView.showsLineSelection = NO;
    [self.view addSubview:self.lineChartView];
    self.lineChartView.clipsToBounds = NO;
    
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
    
    //Set style for labels
    UIColor *currentColor = [UIColor htw_aquaMarineColor];
    UIColor *compareColor = [UIColor htw_squashColor];
    UIColor *standardColor = [UIColor htw_whiteColor];
    self.lblCurrentLocationTemp.textColor = standardColor;
    self.lblCurrentLocationCityState.textColor = currentColor;
    self.lblComparedWeatherLocationTemp.textColor = standardColor;
    self.lblComparedLocationCityState.textColor = compareColor;
    self.lblComparedConditionClimacon.textColor = standardColor;
    self.lblCurrConditionClimacon.textColor = standardColor;
    self.lblCompTime.textColor = compareColor;
    self.lblCurrTime.textColor = currentColor;
    
    //Get current location and update view.
    [self getCurrentLocation];
//    [self.tableSavedLocations reloadData];
}

//Return color for difference in temperature.
-(UIColor *)returnColorDifferenceForHere:(float)here andThere:(float)there {
    if (here > there) {
        float percentDifference = (here-there)/((here+there)/2);
        return [UIColor colorWithRed:1.0-percentDifference green:0.0 blue:1.0 alpha:1.0];
    } else if (here < there) {
        float percentDifference = (there-here)/((here+there)/2);
        return [UIColor colorWithRed:1.0 green:0.0 blue:1.0-percentDifference alpha:1.0];
    } else {
        return [UIColor purpleColor];
    }
    
}

//TODO: Set custom chart attributes and style.
- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex {
    return NO;
}

//- (UIView *)lineChartView:(JBLineChartView *)lineChartView dotViewAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
//    CZWeatherHourlyCondition *curr = [self.currWeatherData.hourlyForecasts objectAtIndex:horizontalIndex];
//    CZWeatherHourlyCondition *comp = [self.compWeatherData.hourlyForecasts objectAtIndex:horizontalIndex];
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    [formatter setDateFormat:@"ha"];
//    if (lineIndex == 0) {
//        self.lblCurrTime = [UILabel new];
//        self.lblCurrTime.text = [NSString stringWithFormat:@"%@",[[formatter stringFromDate:curr.date] lowercaseString]];
//        [self.lblCurrTime sizeToFit];
//        self.lblCurrTime.textColor = [UIColor whiteColor];
//        self.lblCurrTime.hidden = true;
//        return self.lblCurrTime;
//    } else {
//        UILabel *time = [UILabel new];
//        time.text = [NSString stringWithFormat:@"%@",[[formatter stringFromDate:comp.date] lowercaseString]];
//        [time sizeToFit];
//        time.textColor = [UIColor whiteColor];
//        time.hidden = true;
//        return time;
//    }
//}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex {
    return NO;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0) {
        return [UIColor htw_aquaMarineColor];
    } else {
        return [UIColor htw_squashColor];
    }
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0) {
        return [UIColor htw_aquaMarineColor];
    } else {
        return [UIColor htw_squashColor];
    }
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 1.0;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor]; // color of selection view
}

- (CGFloat)verticalSelectionWidthForLineChartView:(JBLineChartView *)lineChartView
{
    return 1.0; // width of selection view
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    if (self.lblCurrTime.hidden || self.lblCompTime.hidden) {
        self.lblCurrTime.hidden = false;
        self.lblCompTime.hidden = false;
    }
    //Retrieve current temperature for selected value.
    float currSelectedTemp = [[[self.allHourlyData objectForKey:@"currentHourlyData"] objectAtIndex:horizontalIndex] floatValue];
    float compSelectedTemp = [[[self.allHourlyData objectForKey:@"comparedHourlyData"] objectAtIndex:horizontalIndex] floatValue];
    
    //Current condition for selected time.
    CZWeatherHourlyCondition *curr = [self.currWeatherData.hourlyForecasts objectAtIndex:horizontalIndex];
    CZWeatherHourlyCondition *comp = [self.compWeatherData.hourlyForecasts objectAtIndex:horizontalIndex];
    
    //Update temp labels for selected time.
    self.lblCurrentLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", currSelectedTemp];
    self.lblComparedWeatherLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", compSelectedTemp];
    
    //Update climacons for selected time.
    self.lblCurrConditionClimacon.text = [NSString stringWithFormat:@"%c", curr.climacon];
    self.lblComparedConditionClimacon.text = [NSString stringWithFormat:@"%c", comp.climacon];
    
    //Update time label for selected time.
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"ha"];
    self.lblCurrTime.text = [NSString stringWithFormat:@"%@",[[formatter stringFromDate:curr.date] lowercaseString]];
    self.lblCompTime.text = [NSString stringWithFormat:@"%@",[[formatter stringFromDate:comp.date] lowercaseString]];
    [self.lblCurrTime sizeToFit];
    [self.lblCompTime sizeToFit];
    
    //Change padding based on data location
    float CHARTPADDING = 10;
    float TIMELABELPADDING = 7.5;

    self.lblCurrTime.center = CGPointMake(touchPoint.x - (self.lblCurrTime.frame.size.width/2) - TIMELABELPADDING, CHARTPADDING);
    self.lblCompTime.center = CGPointMake(touchPoint.x + (self.lblCompTime.frame.size.width/2) +TIMELABELPADDING, CHARTPADDING);
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    if (!self.lblCurrTime.hidden || !self.lblCompTime.hidden) {
        self.lblCurrTime.hidden = true;
        self.lblCompTime.hidden = true;
    }
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
            //Set current hourly condition
            if (current == YES) {
                self.currWeatherData = data;
            } else {
                self.compWeatherData = data;
            }
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
                    weather.summary = h.summary;
                    weather.climacon = h.climacon;
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
        self.lblCurrConditionClimacon.text = [NSString stringWithFormat:@"%c", data.climacon];
        self.lblCurrentLocationCityState.text = [NSString stringWithFormat:@"%@, %@", data.city, data.state];
    } else {
        self.lblComparedWeatherLocationTemp.text = [NSString stringWithFormat:@"%.f\u00B0", data.currTemp];
        self.lblComparedConditionClimacon.text = [NSString stringWithFormat:@"%c", data.climacon];
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
    
    //Find the MIN & MAX to calculate and update time label height.
    if([self.allHourlyData objectForKey:@"currentHourlyData"] && [self.allHourlyData objectForKey:@"comparedHourlyData"]) {
        NSMutableArray *numbers = [NSMutableArray new];
        [numbers addObjectsFromArray:[self.allHourlyData objectForKey:@"currentHourlyData"]];
        [numbers addObjectsFromArray:[self.allHourlyData objectForKey:@"comparedHourlyData"]];
        
        self.chartMax = -MAXFLOAT;
        self.chartMin = MAXFLOAT;
        for (NSNumber *num in numbers) {
            float y = num.floatValue;
            if (y < self.chartMin) self.chartMin = y;
            if (y > self.chartMax) self.chartMax = y;
        }
        NSLog(@"All Numbers:%@, MIN: %.f, MAX: %.f", numbers, self.chartMin, self.chartMax);
        
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
    if (lineIndex == 0) {
        if ([self.allHourlyData objectForKey:@"currentHourlyData"]) {
//            NSLog(@"Line 1: current");
            return [[self.currLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        } else {
//            NSLog(@"Line 1: compared");
            return [[self.compLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        }
    } else {
        if ([self.allHourlyData objectForKey:@"comparedHourlyData"]) {
//            NSLog(@"Line 2: compared");
            return [[self.compLocHourlyData objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
        } else {
//            NSLog(@"Line 2: current");
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
    if (savecVC.selectedLocation) {
        [self returnWeatherForLocation:savecVC.selectedLocation forCurrentView:NO];
    }
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

@end
