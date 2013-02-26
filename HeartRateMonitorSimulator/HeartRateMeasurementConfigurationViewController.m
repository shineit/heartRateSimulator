//
//  HeartRateMeasurementConfigurationViewController.m
//  StaticTableView
//
//  Created by Chip Keyes on 2/22/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "HeartRateMeasurementConfigurationViewController.h"
#import "BLEMeasurementFlagRecord.h"

@interface HeartRateMeasurementConfigurationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flagLabel;

@property (nonatomic, strong)NSString *flagString;

-(void)setCellAccessory:(NSIndexPath *)indexPath forValue:(BOOL)value;


@property (nonatomic, readonly) NSArray *sectionTitles;

@property (nonatomic, strong) NSMutableArray *tableData;

@end

@implementation HeartRateMeasurementConfigurationViewController

@synthesize sectionTitles = _sectionTitles;
@synthesize flagValue = _flagValue;

#define NUMBER_OF_ROWS 9
#define NUMBER_OF_SECTIONS 4

#define MEASUREMENT_IS_TWO_BYTES 1
#define CONTACT_SUPPORTED 2
#define CONTACT_SUPPORTED_NOT_DETECTED 2
#define CONTACT_SUPPORTED_DETECTED 6
#define ENERGY_EXPENDED_PRESENT 8
#define RR_INTERVAL_PRESENT 16


#define FORMAT_ROWS         2
#define SENSOR_CONTACT_ROWS 3
#define ENERGY_ROWS         2
#define RR_ROWS             2


#pragma mark- Properties

-(NSArray *)sectionTitles
{
    if (_sectionTitles == nil)
    {
        _sectionTitles = [NSArray arrayWithObjects:@"Heart Rate Format",@"Sensor Contact", @"Energy Expended", @"RR-Interval", nil];
    }
    return _sectionTitles;
}

-(NSMutableArray *)tableData
{
    NSMutableArray *formatSection;
    NSMutableArray *sensorSection;
    NSMutableArray *energySection;
    NSMutableArray *RRSection;
    BLEMeasurementFlagRecord *record;
    
    if (_tableData == nil)
    {
        _tableData = [NSMutableArray arrayWithCapacity:NUMBER_OF_SECTIONS];
        
        for (NSUInteger section=0; section < NUMBER_OF_SECTIONS; section++)
        {
            switch (section)
            {
                case 0:
                    formatSection = [NSMutableArray arrayWithCapacity:FORMAT_ROWS];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"8 Bit Value" andCheckMark:YES];
                    
                    [formatSection addObject:record];
                    
                    record = [[BLEMeasurementFlagRecord alloc]initWithTitle:@"16 Bit Value" andCheckMark:NO];
                    
                    [formatSection addObject:record];

                    [_tableData addObject:formatSection];
                    break;
                    
                case 1:
                    sensorSection = [NSMutableArray arrayWithCapacity:(NSUInteger)SENSOR_CONTACT_ROWS];
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Not Supported" andCheckMark:YES];
                    [sensorSection addObject:record];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Supported - Contact Not Detected" andCheckMark:NO];
                    [sensorSection addObject:record];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Supported - Contact Detected" andCheckMark:NO];
                    [sensorSection addObject:record];
                                        
                    [_tableData addObject:sensorSection];
                    break;
                    
                case 2:
                    energySection = [NSMutableArray arrayWithCapacity:ENERGY_ROWS];
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Present" andCheckMark:NO];
                    [energySection addObject:record];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Not Present" andCheckMark:YES];
                    [energySection addObject:record];

                                       
                    [_tableData addObject:energySection];
                    break;
                case 3:
                    
                    RRSection = [NSMutableArray arrayWithCapacity:RR_ROWS];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Present" andCheckMark:NO];
                    [RRSection addObject:record];
                    
                    record = [[BLEMeasurementFlagRecord alloc] initWithTitle:@"Not Present" andCheckMark:YES];
                    [RRSection addObject:record];

                    
                    [_tableData addObject:RRSection];
                    break;
                default:
                    break;
            }
        }
    }
    
    return _tableData;
}


-(void)setFlagValue:(unsigned char)flagValue
{
    _flagValue = flagValue;
    
    [self updateTableData];
}

-(unsigned char)flagValue
{
    return _flagValue;
}



-(NSString *)flagString
{
    _flagString=@"  Characteristic Flag Bits= [";
    unsigned char byteArray[8];
    unsigned char temp = self.flagValue;
    for (NSInteger bit = 7; bit >=0; bit--)
    {
        byteArray[bit] = temp & 0x80;
        if (byteArray[bit])
        {
            _flagString = [_flagString stringByAppendingString:@"1"];
        }
        else
        {
            _flagString = [_flagString stringByAppendingString:@"0"];
        }
        temp = temp << 1;
    }
    _flagString = [_flagString stringByAppendingString:@"]"];
    return _flagString;
}



#pragma mark- Private Methods


// Update the table data source with the user selected check mark accessory
-(void)setCellAccessory:(NSIndexPath *)indexPath forValue:(BOOL)value
{
    DLog(@"Entering setCellAccessory");
    DLog(@"Section= %d  Row= %d",indexPath.section, indexPath.row);
    // get the label from the label array and match it to a peripheral invocation
    NSMutableArray *sectionRecords = [self.tableData objectAtIndex:indexPath.section];
    BLEMeasurementFlagRecord *record = (BLEMeasurementFlagRecord*)[sectionRecords objectAtIndex:indexPath.row];
    record.hasCheckMark = value ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
}



/*
 *
 * Method Name:  updateTableData
 *
 * Description:  Updates the table data source in response to user selections or new format flag value from an upstream controller.
 *
 * Parameter(s): none
 *
 */
-(void)updateTableData
{
  
    DLog(@"Entering updateTableData");
    NSIndexPath *indexPath;
    
    // 8 or 16 bit measurement values
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (self.flagValue & MEASUREMENT_IS_TWO_BYTES)
    {
        [self setCellAccessory:indexPath forValue:NO];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self setCellAccessory:indexPath forValue:YES];
    }
    else
    {
        [self setCellAccessory:indexPath forValue:YES];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self setCellAccessory:indexPath forValue:NO];
    }
    
    // contact sensor data
    indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
   
    if ( ! (self.flagValue & CONTACT_SUPPORTED) )
    {
        [self setCellAccessory:indexPath forValue:YES];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        [self setCellAccessory:indexPath forValue:NO];
        indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
        [self setCellAccessory:indexPath forValue:NO];
        
    }
    else
    {
        // contact info is supported
        [self setCellAccessory:indexPath forValue:NO];
        if (( self.flagValue & CONTACT_SUPPORTED_DETECTED) == CONTACT_SUPPORTED_DETECTED)
        {
           
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            [self setCellAccessory:indexPath forValue:NO];
            indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
            [self setCellAccessory:indexPath forValue:YES];
        }
        else
        {
            [self setCellAccessory:indexPath forValue:NO];
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            [self setCellAccessory:indexPath forValue:YES];
            indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
            [self setCellAccessory:indexPath forValue:NO];
        }
    }
    
    // Energy Expended
    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    
    if (self.flagValue & ENERGY_EXPENDED_PRESENT)
    {
        [self setCellAccessory:indexPath forValue:YES];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
        [self setCellAccessory:indexPath forValue:NO];
    }
    else
    {
        [self setCellAccessory:indexPath forValue:NO];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
        [self setCellAccessory:indexPath forValue:YES];
    }
    
    // RR Interval
    indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    
    if (self.flagValue & RR_INTERVAL_PRESENT)
    {
        [self setCellAccessory:indexPath forValue:YES];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:3];
        [self setCellAccessory:indexPath forValue:NO];
    }
    else
    {
        [self setCellAccessory:indexPath forValue:NO];
        indexPath = [NSIndexPath indexPathForRow:1 inSection:3];
        [self setCellAccessory:indexPath forValue:YES];
    }
    
    [self.tableView reloadData];

}



#pragma mark- View Controller Lifecycle

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
    [super viewDidLoad];
    
   

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Flag Value= %u",(unsigned int)self.flagValue);
    self.flagLabel.text = self.flagString;
    
   
}




#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.tableData count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numRowsSection;
    
    numRowsSection = [[self.tableData objectAtIndex:section] count];
    return numRowsSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"flagValue";
    

    //DLog(@"Index= %i",indexPath.row);
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
    // get the label from the label array and match it to a peripheral invocation
    NSMutableArray *sectionRecords = [self.tableData objectAtIndex:indexPath.section];
    BLEMeasurementFlagRecord *record = (BLEMeasurementFlagRecord*)[sectionRecords objectAtIndex:indexPath.row];
    cell.textLabel.text = record.title;
   
    cell.accessoryType = record.hasCheckMark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}




#pragma mark - Table view delegate

/*
 *
 * Method Name:  didSelectRowAtIndexPath:
 *
 * Description:  Update the measurement format flagValue in response to the user selecting an option from the table.
 *
 * Parameter(s): indexPath - indexPath for selected row
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            // Choose either 8-bit or 16-bit heart rate value format
            if (indexPath.row == 0)
            {
                // clear the lsb to indicate 8 bit data
                self.flagValue = self.flagValue & 0xFE;
               
            }
            else
            {
                // set the lsb to indicate 16-bit data
                self.flagValue = self.flagValue | 0x01;
            }
            break;
        case 1:
            // Contact sensor availability
            if (indexPath.row == 0)
            {
                // clear bits 2 & 3
                self.flagValue = self.flagValue & 0xF9;
            }
            else if(indexPath.row == 1)
            {
                // set bit 2, clear bit 3
                self.flagValue = (self.flagValue | 0x02) & 0xFB ;
            }
            else
            {
                // set bits 2 and 3
                self.flagValue = self.flagValue | 0x06;
            }
            break;
        case 2:
            // expended energy availability
            if (indexPath.row == 0)
            {
                // expended energy
                // set bit 4
                 self.flagValue = self.flagValue | 0x08;
            }
            else
            {
                                
                // clear bit 4
                 self.flagValue = self.flagValue & 0xF7;
            }
            break;
        case 3:
            // RR interval availability
            if (indexPath.row == 0)
            {
                // set bit 5
                self.flagValue = self.flagValue | 0x10;
            }
            else
            {
                // clear bit 5
                self.flagValue = self.flagValue & 0xEF;

            }
            break;
    }

   
    self.flagLabel.text = self.flagString;
    
    [self.delegate setHeartRateMeasurementFlag:self.flagValue];
    
}



@end
