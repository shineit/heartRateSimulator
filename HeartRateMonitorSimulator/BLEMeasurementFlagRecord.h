//
//  BLEMeasurementFlagRecord.h
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/25/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEMeasurementFlagRecord : NSObject


// cell title
@property (nonatomic, strong) NSString * title;

// indicates whether checkmark should be displayed
@property (nonatomic, readwrite) BOOL hasCheckMark;

-(id)initWithTitle: (NSString *)title andCheckMark:(BOOL)checkMark;
@end
