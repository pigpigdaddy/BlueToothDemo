//
//  ViewController.m
//  BlueToothDemo
//
//  Created by 林峰 on 14-8-20.
//  Copyright (c) 2014年 pigpigdaddy. All rights reserved.
//

#import "ViewController.h"

static NSString * const kServiceUUID = @"5845C0AF-F55D-43BE-B20A-B4443664F3CE";

static NSString * const kCharacteristicUUID = @"F5C0119C-84A6-4B53-9DF4-1189192107D2";

@interface ViewController ()

@end

@implementation ViewController

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
    
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
            
        case CBPeripheralManagerStatePoweredOn:
            
            [self setupService];
            
            break;
            
        default:
            
            NSLog(@"Peripheral Manager did change state");
            
            break;

    }
    
}

- (void)setupService {
    
    // Creates the characteristic UUID
    
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    // Creates the characteristic
    
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:
                                 
                                 characteristicUUID properties:CBCharacteristicPropertyNotify
                                 
                                                                        value:nil permissions:CBAttributePermissionsReadable];
    
    // Creates the service UUID
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    // Creates the service and adds the characteristic to it
    
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID
                          
                                                        primary:YES];
    
    // Sets the characteristics for this service
    
    [self.customService setCharacteristics:
     
  @[self.customCharacteristic]];
    
    // Publishes the service
    
    [self.peripheralManager addService:self.customService];
    
}


@end
