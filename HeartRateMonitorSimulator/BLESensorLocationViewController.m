//
//  BLESensorLocationViewController.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLESensorLocationViewController.h"

@interface BLESensorLocationViewController ()
@property (nonatomic,strong) NSArray *sensorLocations;
@property (nonatomic, readwrite)NSUInteger checkIndex;
@end

@implementation BLESensorLocationViewController

-(NSArray *)sensorLocations
{
    if (_sensorLocations == nil)
    {
        _sensorLocations = [NSArray arrayWithObjects:@"Chest",@"Wrist",@"Finger",@"Hand",@"Ear Lobe", @"Foot",@"Other",nil];
    }
    
    return _sensorLocations;
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    DLog(@"Entering Table View viewDidLoad");
    [super viewDidLoad];

    self.checkIndex = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
   // [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.sensorLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SensorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text  = [self.sensorLocations objectAtIndex:indexPath.row];
    if (indexPath.row == self.checkIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.checkIndex = indexPath.row;
    // optimize later to just update two rows
    [tableView reloadData];

}

@end
