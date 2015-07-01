//
//  ViewController.h
//  HereThere
//
//  Created by Chad Ackerman on 6/14/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationSearchTableViewController.h"
#import "CZWeatherKit.h"
#import "INTULocationManager.h"
#import "LMGeocoder.h"
#import "BEMSimpleLineGraphView.h"

#import "WeatherData.h"

@interface ViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCurrentWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationCityState;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *chartCurrentWeatherHourly;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *chartComparedWeatherHourly;
@property (weak, nonatomic) IBOutlet UILabel *lblComparedWeatherLocationTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblComparedLocationCityState;

@property (nonatomic) NSMutableArray *currLocHourlyData;
@property (nonatomic) NSMutableArray *compLocHourlyData;
- (IBAction)refreshWeatherData:(id)sender;


- (IBAction)changeLocation:(id)sender;

@end

