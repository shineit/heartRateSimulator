//
//  PeripheralManagerViewController.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

// ****************    This code only supports a single connected subscriber    ****************

#import "PeripheralManagerViewController.h"
#import "BLESensorLocationViewController.h"
#import "HeartRateMeasurementConfigurationViewController.h"


@interface PeripheralManagerViewController ()

// timer which drives the transmission of the heart rate pulse measurement
@property (nonatomic, strong) dispatch_source_t sampleClock;

// queues transmissions to Central
@property (nonatomic,strong) dispatch_queue_t transmitQueue;

// displays CBPeripheralManager status 
@property (weak, nonatomic) IBOutlet UILabel *hostBluetoothStatus;

// displays heart rate value
@property (weak, nonatomic) IBOutlet UILabel *heartRateValueLabel;

// stepper for incrementing heart rate
@property (weak, nonatomic) IBOutlet UIStepper *heartRateStepper;

// the latest heart rate updated from the stepper
@property (atomic, readwrite) unsigned char heartRate;

// outlet for switch used to turn advertising on/off
@property (weak, nonatomic) IBOutlet UISwitch *advertiseSwitchControl;

// peripheralManager property which manages advertising, connection state, etc.
@property (strong, nonatomic)CBPeripheralManager        *peripheralManager;

// the mutable heart rate serve
@property (strong, nonatomic)CBMutableService           *heartRateService;

// the mutable heart rate measurement service
@property (strong, nonatomic)CBMutableCharacteristic    *heartRateMeasurementCharacteristic;

// NSData representation of heart rate measurement 
@property (strong, nonatomic) NSData                    *heartRateData;

@property (nonatomic, readwrite) unsigned char heartRateMeasurementFlag;

// boolean flag indicating whether there are any subscribers to the service
@property (nonatomic, readwrite) BOOL haveSubscriber;

// boolean flag indicating communication channel is ready for more bytes
@property (nonatomic, readwrite) BOOL sendReady;

// advertsing switch handler
- (IBAction)advertiseSwitch:(UISwitch *)sender;

// hert rate stepper handler
- (IBAction)heartRateStepper:(UIStepper *)sender;

@end

//Maximum Transmission Unit -- not currently used since heart rate data is only 2 bytes
#define NOTIFY_MTU 20

@implementation PeripheralManagerViewController

#pragma mark- Properties


// Getter for transmit queue
-(dispatch_queue_t) transmitQueue
{
    if (! _transmitQueue)
    {
        _transmitQueue = dispatch_queue_create("transmitQueue", NULL);
    }
    return _transmitQueue;
}


#define ENERGY_EXPENDED_PRESENT 8

// lazy initializer/getter for heart rate data
-(void)updateHeartRateData
{
    unsigned char data[10];
    NSUInteger dataLength = 0;
    
    data[dataLength++] = self.heartRateMeasurementFlag;
    
    
    DLog(@"Sending Measurement Flag Value %u",self.heartRateMeasurementFlag);
    
    if ( self.heartRateMeasurementFlag & 0x01)
    {
        // send heart rate as 2 bytes        
        unsigned short integerHeartRate = self.heartRate;
        unsigned char lsb = (unsigned char) integerHeartRate & 0xFF;
        data[dataLength++] = lsb;
                
        unsigned char msb = (unsigned char)(integerHeartRate >> 8);
        data[dataLength++] = msb;
               
    }
    else
    {
        data[dataLength++] = self.heartRate;
    }
    
    // check energy expended flag
    if (self.heartRateMeasurementFlag & ENERGY_EXPENDED_PRESENT)
    {
        // add two bytes of energy data
        // use heart rate  * 10 for value
        unsigned short energy = self.heartRate * 10;
        unsigned char lsb = (unsigned char) energy & 0xFF;
        data[dataLength++] = lsb;
       
        
        unsigned char msb = (unsigned char) (energy >> 8);
        data[dataLength++] = msb;
                
    }
    
    // set the data
    self.heartRateData = [NSData dataWithBytes:data length:dataLength];

}


#define SAMPLE_CLOCK_FREQUENCY_HERTZ 1

/*
 *
 * Method Name:  sampleClock
 *
 * Description:  Samples and sends heart rate data to subscribers 
 *    smaple frequency set by SAMPLE_CLOCK_FREQUENCY in viewDidLoad
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


// Increment or decrement heart rate to be sent to subscribers
- (IBAction)heartRateStepper:(UIStepper *)sender
{
    self.heartRate = (unsigned char)sender.value;
    self.heartRateValueLabel.text = [NSString stringWithFormat:@"%u",self.heartRate];
}


// Start or stop advertising based upon switch position
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


#pragma mark- Controller Lifecyle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/*
 *
 * Method Name:  viewDidLoad
 *
 * Description:  View controller initializations
 *
 *    set up UI, initialize scalar properties, start the sample clock
 *
 * Parameter(s): <#parameters#>
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.haveSubscriber = NO;
    
    self.sendReady = YES;
    
    // Measurement is byte and body sensor contact not supported
    _heartRateMeasurementFlag = 0x0;
    
    
	// Do any additional setup after loading the view.
    self.heartRateValueLabel.text = [NSString stringWithFormat:@"%u",(unsigned int)self.heartRateStepper.value];
    
    //start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    
    self.heartRate = (unsigned char)self.heartRateStepper.value;
    
    [self.peripheralManager addService:self.heartRateService];
    
     dispatch_source_set_timer(self.sampleClock, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC / SAMPLE_CLOCK_FREQUENCY_HERTZ, 1ull * NSEC_PER_SEC/100);
    
    dispatch_suspend(self.sampleClock);
}


// Stop the timer
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DLog(@"viewWillDisappear Invoked");
    [self.peripheralManager stopAdvertising];
    dispatch_suspend(self.sampleClock);
 //   self.sampleClock = nil;

    
}

-(void)viewWillAppear:(BOOL)animated
{
    DLog(@"viewWillAppear Invoked");
    [super viewWillAppear:animated];
    
    dispatch_resume(_sampleClock);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Seque to the embedded table view controller with body sensor location choices
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowSensorLocation"])
    {
       
        if ([segue.destinationViewController isKindOfClass:[BLESensorLocationViewController class]])
        {
           // nothing needed at this time
        }
    }
    else if  ([segue.identifier isEqualToString:@"ConfigureMeasurement"])
    {
        if ([segue.destinationViewController isKindOfClass:[HeartRateMeasurementConfigurationViewController class]])
        {
            HeartRateMeasurementConfigurationViewController *destination = (HeartRateMeasurementConfigurationViewController *)segue.destinationViewController;
            
            destination.delegate = self;
            
            destination.flagValue = self.heartRateMeasurementFlag;
            
        }
    }
}


#pragma mark- Private Methods

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
            // log data that was sent
            const uint8_t *reportData = [self.heartRateData  bytes];
            
            NSUInteger bpm;
            
            NSUInteger flag = reportData[0];
            DLog(@"flag = %i",flag);
            
            if (flag & 0x01)
            {
                // 16 bits of heart rate data
                bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
                
            }
            else
            {
                bpm = reportData[1];
            }
        
            DLog(@"Heart Rate Measurement Sent: %u",bpm);
            
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

#pragma mark- BLEHeartRateConfigurationProtocol
-(void)setHeartRateMeasurementFlag: (unsigned char)flag
{
    
    _heartRateMeasurementFlag = flag;
    DLog(@"heartRateMeasurementFlag Updated %d",flag);
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


//Catch when someone subscribes to our characteristic, then start sending them data
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    DLog(@"Central subscribed to characteristic");
    self.haveSubscriber = YES;
}


// Recognise when the central unsubscribes
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    DLog(@"Central unsubscribed from characteristic");
    self.haveSubscriber = NO;
}


// This callback comes in when the PeripheralManager is ready to send the next chunk of data.
// This is to ensure that packets will arrive in the order they are sent
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"PeripheralManagerIsReadyToUpdateSubscribers");
    self.sendReady = YES;
    
}

@end
