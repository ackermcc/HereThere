//
//  SavedLocationsTableViewController.h
//  HereThere
//
//  Created by Chad Ackerman on 7/29/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SavedLocationsTableViewController : UITableViewController
- (IBAction)dismissSavedLocationsController:(id)sender;
@property (nonatomic) CLLocation *selectedLocation;

@end
