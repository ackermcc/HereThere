//
//  LocationSearchTableViewController.h
//  HereThere
//
//  Created by Chad Ackerman on 6/18/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface LocationSearchTableViewController : UITableViewController <UISearchBarDelegate>
- (IBAction)dismissSearchController:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *geoSearchBar;
@property (nonatomic) NSMutableArray *searchResults;
@property (nonatomic) NSMutableDictionary *selectedLocation;
@end
