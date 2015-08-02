//
//  ViewController.h
//  HereThere
//
//  Created by Chad Ackerman on 6/14/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationSearchTableViewController.h"
#import "SavedLocationsTableViewController.h"
#import "CZWeatherKit.h"
#import "INTULocationManager.h"
#import "LMGeocoder.h"
//#import "BEMSimpleLineGraphView.h"

#import "JBChartView.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"

#import "WeatherData.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationCityState;
@property (weak, nonatomic) IBOutlet UILabel *lblComparedWeatherLocationTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblComparedLocationCityState;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrConditionClimacon;
@property (weak, nonatomic) IBOutlet UILabel *lblComparedConditionClimacon;

@property (nonatomic) NSMutableArray *currLocHourlyData;
@property (nonatomic) NSMutableArray *compLocHourlyData;
@property (nonatomic) NSMutableDictionary *allHourlyData;

- (IBAction)refreshWeatherData:(id)sender;
- (IBAction)unwindFromSavedLocations:(UIStoryboardSegue *)segue;

@property (nonatomic) JBLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UIButton *lblAddLocation;

//TODO: get rid of
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *chartCurrentWeatherHourly;
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *chartComparedWeatherHourly;
//@property (weak, nonatomic) IBOutlet UIView *viewCurrentWeather;
//@property (weak, nonatomic) IBOutlet UIView *viewComparedWeather;
//@property (weak, nonatomic) IBOutlet UITableView *tableSavedLocations;
- (IBAction)changeLocation:(id)sender;

@end

