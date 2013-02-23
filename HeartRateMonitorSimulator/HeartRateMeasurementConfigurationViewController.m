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
@property (nonatomic, readwrite)unsigned char flagValue;
@property (nonatomic, strong)NSString *flagString;

@end

@implementation HeartRateMeasurementConfigurationViewController

#define NUMBER_OF_ROWS 9
#define NUMBER_OF_SECTIONS 4

#define MEASUREMENT_IS_TWO_BYTES 1
#define BODY_SENSOR_CONTACT_NOT_SUPPORTED  6
#define CONTACT_NOT_DETECTED 8
#define CONTACT_DETECTED 16
#define ENERGY_EXPENDED_PRESENT 32
#define RR_INTERVAL_PRESENT 64


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

-(unsigned char) flagValue
{
    _flagValue = 0;
    UITableViewCell* cell;
    UITableViewCellAccessoryType accessory;
    for (NSUInteger section = 0; section < NUMBER_OF_SECTIONS; section++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        accessory = cell.accessoryType;
        
        switch (section)
        {
            case 0:
               
                if (accessory == UITableViewCellAccessoryNone)
                {
                    // the measurement is formatted as 16 bits
                    _flagValue += MEASUREMENT_IS_TWO_BYTES;
                }
                break;
            case 1:
                if (accessory == UITableViewCellAccessoryCheckmark)
                {
                    _flagValue +=BODY_SENSOR_CONTACT_NOT_SUPPORTED;
                }
                else
                {
                    indexPath = [NSIndexPath indexPathForRow:1 inSection:section];
                    cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    accessory = cell.accessoryType;
                    if (accessory == UITableViewCellAccessoryCheckmark)
                    {
                        _flagValue +=CONTACT_NOT_DETECTED;
                    }
                    else
                    {
                        _flagValue +=CONTACT_DETECTED;
                    }
                }
                break;
                
            case 2:
                if (accessory == UITableViewCellAccessoryCheckmark)
                {
                    _flagValue +=ENERGY_EXPENDED_PRESENT;
                }
                break;
                
            case 3:
                if (accessory == UITableViewCellAccessoryCheckmark)
                {
                    _flagValue +=RR_INTERVAL_PRESENT;
                }
                
                break;
        }
    }
    
    self.delegate.heartRateMeasurementFlag = _flagValue;
    
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
    

}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Flag Value= %u",(unsigned int)self.flagValue);
    self.flagLabel.text = self.flagString;
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
               
            }
            else
            {
                //16 bit heart rate measurement
                [self setCellAccessory:indexPath forValue:YES];
                
                // 8 bit heart rate measurement
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
            }
            break;
        case 1:
            if (indexPath.row == 0)
            {
                // sensor contact not supported
                [self setCellAccessory:indexPath forValue:YES];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                
            }
            else if(indexPath.row == 1)
            {
                // sensor contact not detected
                [self setCellAccessory:indexPath forValue:YES];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
                
            }
            else
            {
                //sensor contact supported
                [self setCellAccessory:indexPath forValue:YES];
                
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
                
                temp = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];
            }
            else
            {
                [self setCellAccessory:indexPath forValue:YES];
                
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

            }
            else
            {
                [self setCellAccessory:indexPath forValue:YES];
                
                temp = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                [self setCellAccessory:temp forValue:NO];

            }
            break;
    }

     NSLog(@"Flag Value= %u",(unsigned int)self.flagValue);
    self.flagLabel.text = self.flagString;
}



@end
