//
//  PeripheralManagerViewController.m
//  HeartRateMonitorSimulator
//
//  Created by Chip Keyes on 2/20/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "PeripheralManagerViewController.h"

@interface PeripheralManagerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *heartRateValueLabel;
- (IBAction)heartRateStepper:(UIStepper *)sender;
@property (weak, nonatomic) IBOutlet UIStepper *heartRateStepper;

@property (atomic, readwrite) unsigned char heartRate;


- (IBAction)advertiseSwitch:(UISwitch *)sender;

@end

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
@end
