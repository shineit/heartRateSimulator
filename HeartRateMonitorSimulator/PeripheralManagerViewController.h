//
//  PeripheralManagerViewController.h
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEHeartRateConfigurationProtocol.h"

@interface PeripheralManagerViewController : UIViewController <CBPeripheralManagerDelegate, BLEHeartRateConfigurationProtocol>

@property (nonatomic, readwrite) unsigned char heartRateMeasurementFlag;

@end
