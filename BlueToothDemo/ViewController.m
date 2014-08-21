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

@property (nonatomic, strong)UIButton *btnNext;
@property (nonatomic, strong)UIButton *btnLast;
@property (nonatomic, strong)UILabel *labelStatus;
@property (nonatomic, strong)UIButton *btnStart;

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
    
    [self initView];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)initView
{
    self.btnLast = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnLast.frame = CGRectMake(50, 100, 60, 40);
    [self.btnLast setTitle:@"上一个" forState:UIControlStateNormal];
    self.btnLast.enabled = NO;
    self.btnLast.tag = 100;
    [self.btnLast addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnLast];
    
    self.btnNext = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnNext.frame = CGRectMake(210, 100, 60, 40);
    [self.btnNext setTitle:@"下一个" forState:UIControlStateNormal];
    self.btnNext.enabled = NO;
    self.btnNext.tag = 200;
    [self.btnNext addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnNext];
    
    self.labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 50)];
    self.labelStatus.font = [UIFont systemFontOfSize:22];
    self.labelStatus.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelStatus];
    
    self.btnStart = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnStart.frame = CGRectMake(100, 200, 120, 40);
    [self.btnStart setTitle:@"重新启动服务" forState:UIControlStateNormal];
    [self.btnStart addTarget:self action:@selector(startbuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnStart];
}

- (void)buttonAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:
        {
            [self.peripheralManager updateValue:[@"100" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.customCharacteristic onSubscribedCentrals:nil];
        }
            break;
        case 200:
        {
            [self.peripheralManager updateValue:[@"200" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.customCharacteristic onSubscribedCentrals:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)startbuttonAction:(id)sender
{
    [self setupService];
}

- (void)setupService{
    // 创建一个特征
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    // 创建一个服务
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // 将特征放进服务中
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    
    // 将服务放进特征中
    [self.peripheralManager addService:self.customService];
    
    self.labelStatus.text = @"正在等待中央连接......";
}

#pragma mark
#pragma mark ============ CBPeripheralManagerDelegate ============
// 添加了服务
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey:@"ICServer",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUUID]]}];
    }
}

// 周边管理者更新了状态
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            [self setupService];
        }
            break;
        default:
        {
            NSLog(@"Peripheral Manager did change state");
        }
            break;
    }
}

// 周边开始广播
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    // 什么都不用做
}

// 中央订阅了特征
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    // 为中央生成动态数据 发送数据
    self.btnNext.enabled = YES;
    self.btnLast.enabled = YES;
    self.labelStatus.text = @"中央已连接";
}

// 中央取消了订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central Unsubscribe Character");
    self.btnNext.enabled = NO;
    self.btnLast.enabled = NO;
    self.labelStatus.text = @"正在等待中央连接......";
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
}


@end
