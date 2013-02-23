//
//  HeartRateMeasurementConfigurationViewController.h
//  StaticTableView
//
//  Created by Chip Keyes on 2/22/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEHeartRateConfigurationProtocol.h"

@interface HeartRateMeasurementConfigurationViewController : UITableViewController

@property (nonatomic, weak) id<BLEHeartRateConfigurationProtocol> delegate;

@end
