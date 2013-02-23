//
//  HeartRateMeasurementConfigurationViewController.m
//  StaticTableView
//
//  Created by Chip Keyes on 2/22/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "HeartRateMeasurementConfigurationViewController.h"

@interface HeartRateMeasurementConfigurationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flagLabel;

@property (nonatomic, strong)NSString *flagString;

-(void)setCellAccessory:(NSIndexPath *)indexPath forValue:(BOOL)value;

@end

@implementation HeartRateMeasurementConfigurationViewController

@synthesize flagValue = _flagValue;

#define NUMBER_OF_ROWS 9
#define NUMBER_OF_SECTIONS 4

#define MEASUREMENT_IS_TWO_BYTES 1
#define CONTACT_SUPPORTED 2
#define CONTACT_SUPPORTED_NOT_DETECTED 2
#define CONTACT_SUPPORTED_DETECTED 6
#define ENERGY_EXPENDED_PRESENT 8
#define RR_INTERVAL_PRESENT 16



-(void)updateTable
{
    NSIndexPath *indexPath;
    UITableViewCell* cell;
    
    // 8 or 16 bit measurement values
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
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
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
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
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
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
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
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

}

-(void)setFlagValue:(unsigned char)flagValue
{
    _flagValue = flagValue;
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


-(unsigned char)flagValue
{
    return _flagValue;
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
    [super viewDidLoad];
    
    [self updateTable];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Flag Value= %u",(unsigned int)self.flagValue);
    self.flagLabel.text = self.flagString;
    
    [self updateTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setCellAccessory:(NSIndexPath *)indexPath forValue:(BOOL)value
{
    UITableViewCell* cell;
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = value ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *temp;
    switch (indexPath.section)
    {
        case 0:
            if (indexPath.row == 0)
            {
                // 8 bit heart rate measurement
                [self setCellAccessory:indexPath forValue:YES];
                
                //16 bit heart rate measurement
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                // clear the lsb to indicate 8 bit data
                self.flagValue = self.flagValue & 0xFE;
               
            }
            else
            {
                //16 bit heart rate measurement
                [self setCellAccessory:indexPath forValue:YES];
                
                // 8 bit heart rate measurement
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                // set the lsb to indicate 16-bit data
                self.flagValue = self.flagValue | 0x01;
            }
            break;
        case 1:
            if (indexPath.row == 0)
            {
                // sensor contact not supported
                [self setCellAccessory:indexPath forValue:YES];
                
                // clear bits 2 & 3
                self.flagValue = self.flagValue & 0xF9;
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                
            }
            else if(indexPath.row == 1)
            {
                // sensor contact not detected
                [self setCellAccessory:indexPath forValue:YES];
                
                // set bit 2, clear bit 3
                self.flagValue = self.flagValue | 0x02;
                self.flagValue = self.flagValue & 0xFB;
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
            }
            else
            {
                //sensor contact detected
                [self setCellAccessory:indexPath forValue:YES];
                
                // set bits 2 and 3
                self.flagValue = self.flagValue | 0x06;
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-2 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
            }
            break;
        case 2:
            if (indexPath.row == 0)
            {
               [self setCellAccessory:indexPath forValue:YES];
                
                // expended energy
                // set bit 4
                 self.flagValue = self.flagValue | 0x08;
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
            }
            else
            {
                [self setCellAccessory:indexPath forValue:YES];
                
                // clear bit 4
                 self.flagValue = self.flagValue & 0xF7;
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
            }
            break;
        case 3:
            if (indexPath.row == 0)
            {
                [self setCellAccessory:indexPath forValue:YES];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                // set bit 5
                self.flagValue = self.flagValue | 0x10;

            }
            else
            {
                [self setCellAccessory:indexPath forValue:YES];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                // clear bit 5
                self.flagValue = self.flagValue & 0xEF;

            }
            break;
    }

   
    self.flagLabel.text = self.flagString;
    
    [self.delegate setHeartRateMeasurementFlag:_flagValue];
}



@end
