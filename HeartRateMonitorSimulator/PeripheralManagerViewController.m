//
//  PeripheralManagerViewController.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "PeripheralManagerViewController.h"
#import "BLESensorLocationViewController.h"

#define SAMPLE_CLOCK_FREQUENCY_HERTZ 1

@interface PeripheralManagerViewController ()

// timer which drives the transmission of the heart rate pulse measurement
@property (nonatomic, strong) dispatch_source_t sampleClock;

// queues transmissions to Centrals
@property (nonatomic,strong) dispatch_queue_t transmitQueue;


// displays CBCentralManager status (role of iphone/ipad)
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;


@property (weak, nonatomic) IBOutlet UILabel *heartRateValueLabel;

@property (weak, nonatomic) IBOutlet UIStepper *heartRateStepper;

@property (atomic, readwrite) unsigned char heartRate;
@property (weak, nonatomic) IBOutlet UISwitch *advertiseSwitchControl;

- (IBAction)advertiseSwitch:(UISwitch *)sender;
- (IBAction)heartRateStepper:(UIStepper *)sender;

@property (strong, nonatomic)CBPeripheralManager        *peripheralManager;
@property (strong, nonatomic)CBMutableService           *heartRateService;
@property (strong, nonatomic)CBMutableCharacteristic    *heartRateMeasurementCharacteristic;
@property (strong, nonatomic) NSData                    *heartRateData;


@property (nonatomic, readwrite) BOOL haveSubscriber;
@property (nonatomic, readwrite) BOOL sendReady;

@end

//Maximum Transmission Unit
#define NOTIFY_MTU 20

@implementation PeripheralManagerViewController


-(dispatch_queue_t) transmitQueue
{
    if (! _transmitQueue)
    {
        _transmitQueue = dispatch_queue_create("transmitQueue", NULL);
    }
    return _transmitQueue;
}


-(void)updateHeartRateData
{
    unsigned char data[2];
    // first byte encodes information
    // lsb indicates byte or integer type for measurement  (0 -> byte)
    // bit 1 is sensor contact state  (1 -> good)
    // bit 2 indicates whether contact state bit is valid (1 is valid)
    // 6 -> byte data, good sensor contact
    data[0] = 6;
    
    data[1] = self.heartRate;
    
    // set the data
    self.heartRateData = [NSData dataWithBytes:data length:2];
}


/*
 *
 * Method Name:  sampleClock
 *
 * Description:  
 *
 * Parameter(s): None
 *
 */
-(dispatch_source_t)sampleClock
{
    if (! _sampleClock)
    {
        _sampleClock = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, self.transmitQueue);
        
        dispatch_source_set_event_handler(_sampleClock, ^{
            
            dispatch_async(self.transmitQueue, ^{
                if ( self.haveSubscriber)
                {
                    [self updateHeartRateData];
                    [self sendData];
                }
            });
        });
        
        dispatch_resume(_sampleClock);
    }
    return _sampleClock;
}



#define HEART_RATE_MEASUREMENT_CHARACTERISTIC     @"2A37" 
-(CBMutableCharacteristic *)heartRateMeasurementCharacteristic
{
    if (_heartRateMeasurementCharacteristic == nil)
    {
        _heartRateMeasurementCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_CHARACTERISTIC] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    }
    
    return _heartRateMeasurementCharacteristic;
}

#define HEART_RATE_MEASUREMENT_SERVICE @"180D"
-(CBMutableService *)heartRateService
{
    if (_heartRateService == nil)
    {
        _heartRateService = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_SERVICE] primary:YES];
        
        _heartRateService.characteristics = [NSArray arrayWithObject:self.heartRateMeasurementCharacteristic];
    }
    
    return _heartRateService;
}

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
    
    self.haveSubscriber = NO;
    
    self.sendReady = YES;
    
	// Do any additional setup after loading the view.
    self.heartRateValueLabel.text = [NSString stringWithFormat:@"%u",(unsigned int)self.heartRateStepper.value];
    
    //start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    
    self.heartRate = (unsigned char)self.heartRateStepper.value;
    
    [self.peripheralManager addService:self.heartRateService];
    
     dispatch_source_set_timer(self.sampleClock, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC / SAMPLE_CLOCK_FREQUENCY_HERTZ, 1ull * NSEC_PER_SEC/100);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.peripheralManager stopAdvertising];
    dispatch_source_cancel(self.sampleClock);
    self.sampleClock = nil;

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Seque tothe embedded discovered services table view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowSensorLocations"])
    {
       
        if ([segue.destinationViewController isKindOfClass:[BLESensorLocationViewController class]])
        {
           
        }
    }
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
        DLog(@"Advertising");
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_SERVICE]]}];
    }
    else
    {
        DLog(@"Stop Advertising");
        [self.peripheralManager stopAdvertising];
        
    }
}

/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    DLog(@"Entering sendData");
    

    if (self.sendReady)
    {
        
        // Send it
        bool success = [self.peripheralManager updateValue:self.heartRateData forCharacteristic:self.heartRateMeasurementCharacteristic onSubscribedCentrals:nil];
        
        if (success)
        {
            // force the peripheralManager to allow the next transmission to occur
            //self.sendReady = NO;
            const uint8_t *reportData = [self.heartRateData  bytes];
            
            NSUInteger flag = reportData[0];
            DLog(@"flag = %i",flag);
            
            NSUInteger bpm = 0;
            bpm = reportData[1];
            
            DLog(@"Heart Rate Measurement Sent: %i",bpm);
            
        }
        
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
        
        self.advertiseSwitchControl.enabled = YES;
    }
    else if ( (peripheralManager.state == CBPeripheralManagerStateUnknown) ||
             (peripheralManager.state == CBPeripheralManagerStateResetting) )
        
    {
        self.hostBluetoothStatus.textColor = [UIColor blackColor];
        self.advertiseSwitchControl.enabled = NO;
    }
    else
    {
        self.hostBluetoothStatus.textColor = [UIColor redColor];
        self.advertiseSwitchControl.enabled = NO;
    }
    
    self.hostBluetoothStatus.text = [[self class ] getCBPeripheralStateName: peripheralManager.state];

}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    DLog(@"Central subscribed to characteristic");
    self.haveSubscriber = YES;
    
    
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    DLog(@"Central unsubscribed from characteristic");
    self.haveSubscriber = NO;
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"PeripheralManagerIsReadyToUpdateSubscribers");
    self.sendReady = YES;
    
}

@end
