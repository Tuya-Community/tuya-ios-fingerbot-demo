//
//  DualModeTableViewController.m
//  tuya-fingerbot-ios-objc_Example
//
//  Created by Gino on 2021/4/20.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "DualModeTableViewController.h"
#import "SVProgressHUD.h"
#import "Home.h"

@interface DualModeTableViewController () <TuyaSmartBLEManagerDelegate, TuyaSmartBLEWifiActivatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dualSsidTextField;
@property (weak, nonatomic) IBOutlet UITextField *dualPasswordTextField;

@property (assign, nonatomic) bool isSuccess;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) NSMutableArray *ctrlArray;
@end

@implementation DualModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultArray = [NSMutableArray new];
    self.ctrlArray = [NSMutableArray new];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopConfiguring];
}
- (IBAction)searchTapped:(UIBarButtonItem *)sender {
    [TuyaSmartBLEManager sharedInstance].delegate = self;
    [[TuyaSmartBLEManager sharedInstance] startListening:NO];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"")];
}

- (void)stopConfiguring {
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    [TuyaSmartBLEManager sharedInstance].delegate = nil;
    [[TuyaSmartBLEManager sharedInstance] stopListening:NO];
    
    [TuyaSmartBLEWifiActivator sharedInstance].bleWifiDelegate = nil;
    [[TuyaSmartBLEWifiActivator sharedInstance] stopDiscover];
}

-(void)didDiscoveryDeviceWithDeviceInfo:(TYBLEAdvModel *)deviceInfo {
    if (deviceInfo.bleType != TYSmartBLETypeBLEWifiSecurity && deviceInfo.bleType != TYSmartBLETypeBLEWifiPlugPlay) {
        return;
    }
    [self.resultArray addObject:deviceInfo];
    [[TuyaSmartBLEManager sharedInstance] queryNameWithUUID:deviceInfo.uuid productKey:deviceInfo.productId success:^(NSString * _Nonnull name) {
        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", @"") message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Start Pairing", @""), name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Pairing", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            for (UIAlertController *alertCtrl in self.ctrlArray) {
                if (alertCtrl) {
                    [alertCtrl.navigationController popViewControllerAnimated:YES];
                }
            }
            long long homeId = [Home getCurrentHome].homeId;
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Activating", @"")];
            
            [TuyaSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
            
            [[TuyaSmartBLEWifiActivator sharedInstance] startConfigBLEWifiDeviceWithUUID:deviceInfo.uuid homeId:homeId productId:deviceInfo.productId ssid:self.dualSsidTextField.text password:self.dualPasswordTextField.text timeout:100 success:^{
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
            } failure:^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to activate the Bluetooth LE device.", @"")];
            }];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        
        [alertViewController addAction:action];
        [alertViewController addAction:cancelAction];
        [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
        [self.ctrlArray addObject:alertViewController];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to activate the Bluetooth LE device.", @"")];
    }];
}

-(void)bleWifiActivator:(TuyaSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(TuyaSmartDeviceModel *)deviceModel error:(NSError *)error {
    NSString *name = deviceModel.name?deviceModel.name:NSLocalizedString(@"Unknown Name", @"");
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Successfully Added", @"") ,name]];
    self.isSuccess = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
