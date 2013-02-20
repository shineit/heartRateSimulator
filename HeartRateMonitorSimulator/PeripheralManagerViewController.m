//
//  PeripheralManagerViewController.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "PeripheralManagerViewController.h"

@interface PeripheralManagerViewController ()


// displays CBCentralManager status (role of iphone/ipad)
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;


@property (weak, nonatomic) IBOutlet UILabel *heartRateValueLabel;

@property (weak, nonatomic) IBOutlet UIStepper *heartRateStepper;

@property (atomic, readwrite) unsigned char heartRate;

- (IBAction)advertiseSwitch:(UISwitch *)sender;
- (IBAction)heartRateStepper:(UIStepper *)sender;

@property (strong, nonatomic)CBPeripheralManager *peripheralManager;
@property (strong, nonatomic)CBMutableCharacteristic    *heartRateMeasurement;
@property (strong, nonatomic) NSData  *heartRateData;
@property (nonatomic, readwrite) NSInteger sendDataIndex;

@end

//Maximum Transmission Unit
#define NOTIFY_MTU 20

@implementation PeripheralManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.heartRateValueLabel.text = [NSString stringWithFormat:@"%u",(unsigned int)self.heartRateStepper.value];
    
    //start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)heartRateStepper:(UIStepper *)sender
{
    self.heartRate = (unsigned char)sender.value;
    self.heartRateValueLabel.text = [NSString stringWithFormat:@"%u",self.heartRate];
}

- (IBAction)advertiseSwitch:(UISwitch *)sender
{
    if (sender.on)
    {
        DLog(@"Switch On");
    }
    else
    {
        DLog(@"Switch Off");
    }
}










// Converts CBCentralManagerState to a string... implement as a category on CBCentralManagerState?
+(NSString *)getCBPeripheralStateName:(CBPeripheralManagerState) state
{
    NSString *stateName;
    
    switch (state) {
        case CBPeripheralManagerStatePoweredOn:
            stateName = @"Bluetooth Powered On - Ready";
            break;
        case CBPeripheralManagerStateResetting:
            stateName = @"Resetting";
            break;
            
        case CBPeripheralManagerStateUnsupported:
            stateName = @"Unsupported";
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            stateName = @"Unauthorized";
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            stateName = @"Bluetooth Powered Off";
            break;
            
        default:
            stateName = @"Unknown";
            break;
    }
    return stateName;
}



#pragma mark- CBPeripheralManagerDelegate Protocol Methods
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
     DLog(@"Peripheral Manager Delegate DidUpdate State Invoked");
    
    if (peripheralManager.state ==CBCentralManagerStatePoweredOn)
    {
        self.hostBluetoothStatus.textColor = [UIColor greenColor];
    }
    else if ( (peripheralManager.state == CBPeripheralManagerStateUnknown) ||
             (peripheralManager.state == CBPeripheralManagerStateResetting) )
        
    {
        self.hostBluetoothStatus.textColor = [UIColor blackColor];
    }
    else
    {
        self.hostBluetoothStatus.textColor = [UIColor redColor];
    }
    
    self.hostBluetoothStatus.text = [[self class ] getCBPeripheralStateName: peripheralManager.state];

    
//    // Opt out from any other state
//    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
//        return;
//    }
//    
//    // We're in CBPeripheralManagerStatePoweredOn state...
//    NSLog(@"self.peripheralManager powered on.");
//    
//    // ... so build our service.
//    
//    // Start with the CBMutableCharacteristic
//    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
//                                                                     properties:CBCharacteristicPropertyNotify
//                                                                          value:nil
//                                                                    permissions:CBAttributePermissionsReadable];
//    
//    // Then the service
//    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
//                                                                       primary:YES];
//    
//    // Add the characteristic to the service
//    transferService.characteristics = @[self.transferCharacteristic];
//    
//    // And add it to the peripheral manager
//    [self.peripheralManager addService:transferService];
}

@end
