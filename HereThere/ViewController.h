//
//  ViewController.h
//  HereThere
//
//  Created by Chad Ackerman on 6/14/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZWeatherKit.h"
#import "INTULocationManager.h"
#import "LMGeocoder.h"
#import "BEMSimpleLineGraphView.h"

@interface ViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationCityState;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *viewLineGraph;

@property (nonatomic) NSMutableArray *graphPoints;

@end

