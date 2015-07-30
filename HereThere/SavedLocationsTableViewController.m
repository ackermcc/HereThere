//
//  SavedLocationsTableViewController.m
//  HereThere
//
//  Created by Chad Ackerman on 7/29/15.
//  Copyright (c) 2015 Chad Ackerman. All rights reserved.
//

#import "SavedLocationsTableViewController.h"

@interface SavedLocationsTableViewController ()

@end

@implementation SavedLocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"] count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"savedLocation"];

    NSArray *l = [[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [[l objectAtIndex:indexPath.row] valueForKey:@"city"], [[l objectAtIndex:indexPath.row] valueForKey:@"state"]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *l = [[NSUserDefaults standardUserDefaults] arrayForKey:@"savedLocations"];
    NSNumber *lat = [[l objectAtIndex:indexPath.row] valueForKey:@"lat"];
    NSNumber *lng = [[l objectAtIndex:indexPath.row] valueForKey:@"lng"];

    CLLocationDegrees latitude = [lat floatValue];
    CLLocationDegrees longitude = [lng floatValue];

    CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    self.selectedLocation = aLocation;
    [self performSegueWithIdentifier:@"selectSavedLocation" sender:self];
//    [self returnWeatherForLocation:aLocation forCurrentView:NO];

//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.viewComparedWeather.frame = CGRectMake(self.viewComparedWeather.frame.origin.x, self.viewComparedWeather.frame.origin.y / 2, self.viewComparedWeather.frame.size.width, self.viewComparedWeather.frame.size.height);
//    } completion:^(BOOL complete){
//        [self.tableSavedLocations deselectRowAtIndexPath:indexPath animated:YES];
//    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissSavedLocationsController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
