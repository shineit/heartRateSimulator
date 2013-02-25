//
//  BLEMeasurementFlagRecord.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/25/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEMeasurementFlagRecord.h"

@implementation BLEMeasurementFlagRecord

-(id)init
{
    self = [super init];
    if (self)
    {
        _title = nil;
        _hasCheckMark = NO;
    }
    
    return self;
}

-(id)initWithTitle: (NSString *)title andCheckMark:(BOOL)checkMark
{
    self = [super init];
    if (self)
    {
        _title = title;
        _hasCheckMark = checkMark;
    }
    
    return self;
}

@end
