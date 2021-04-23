//
//  DeviceListTableViewController.m
//  tuya-fingerbot-ios-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import "DeviceControlTableViewController.h"
#import "FingerBotPanelViewController.h"
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import <TYModuleServices/TYSmartHomeDataProtocol.h>
#import <TYModuleServices/TYPanelProtocol.h>

@interface DeviceListTableViewController () <TuyaSmartHomeDelegate>
@property (strong, nonatomic) TuyaSmartHome *home;
@end

@implementation DeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHomeDataProtocol) withInstance:self];
        [self updateHomeDetail];
    }
}

- (TuyaSmartHome *)getCurrentHome {
    return self.home;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.home?self.home.deviceList.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device-list-cell" forIndexPath:indexPath];
    TuyaSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
    cell.textLabel.text = deviceModel.name;
    cell.detailTextLabel.text = deviceModel.isOnline ? NSLocalizedString(@"Online", @"") : NSLocalizedString(@"Offline", @"");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.home.deviceList[indexPath.row].productId isEqualToString:@"y6kttvd6"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FingerBot" bundle:nil];
        FingerBotPanelViewController *fingerBotVC = [storyboard instantiateViewControllerWithIdentifier:@"FingerBotPanelViewController"];
        NSString *deviceID = self.home.deviceList[indexPath.row].devId;
        TuyaSmartDevice *device = [TuyaSmartDevice deviceWithDeviceId:deviceID];
        fingerBotVC.device = device;
        [self.navigationController pushViewController:fingerBotVC animated:YES];
    } else {
        NSString *deviceID = self.home.deviceList[indexPath.row].devId;
        TuyaSmartDevice *device = [TuyaSmartDevice deviceWithDeviceId:deviceID];
        id<TYPanelProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYPanelProtocol)];
        [impl getPanelViewControllerWithDeviceModel:device.deviceModel initialProps:nil contextProps:nil completionHandler:^(__kindof UIViewController * _Nullable panelViewController, NSError * _Nullable error) {
            [self.navigationController pushViewController:panelViewController animated:YES];
        }];
    }
}

- (void)updateHomeDetail {
    [self.home getHomeDetailWithSuccess:^(TuyaSmartHomeModel *homeModel) {
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to get the home.", @"") message:error.localizedDescription];
    }];
}

- (void)homeDidUpdateInfo:(TuyaSmartHome *)home {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home didAddDeivice:(TuyaSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home didRemoveDeivice:(NSString *)devId {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home deviceInfoUpdate:(TuyaSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home device:(TuyaSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationBar setBarTintColor:UIColor.whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationItem setHidesBackButton:NO];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController.navigationBar.backItem setHidesBackButton:NO];
}
@end
