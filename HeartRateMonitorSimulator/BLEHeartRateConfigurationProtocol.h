//
//  BLEHeartRateConfigurationProtocol.h
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/23/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLEHeartRateConfigurationProtocol <NSObject>

@property (nonatomic, readwrite) unsigned char heartRateMeasurementFlag;
@end
