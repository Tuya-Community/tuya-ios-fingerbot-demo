//
//  BLEModeViewController.m
//  tuya-fingerbot-ios-objc_Example
//
//  Created by Gino on 2021/4/9.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "BLEModeViewController.h"
#import "SVProgressHUD.h"
#import "Home.h"

@interface BLEModeViewController () <TuyaSmartBLEManagerDelegate>
@property(assign, nonatomic)bool isSuccess;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) NSMutableArray *ctrlArray;
@end

@implementation BLEModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultArray = [NSMutableArray new];
    self.ctrlArray = [NSMutableArray new];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopConfigBLE];
}

- (IBAction)searchTapped:(UIBarButtonItem *)sender {
    [TuyaSmartBLEManager sharedInstance].delegate = self;
    // Start finding un-paired BLE devices.
    [[TuyaSmartBLEManager sharedInstance] startListening:NO];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"")];
}

- (void)didDiscoveryDeviceWithDeviceInfo:(TYBLEAdvModel *)deviceInfo {
    if (deviceInfo.bleType != TYSmartBLETypeBLESecurity) {
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
            [[TuyaSmartBLEManager sharedInstance] activeBLE:deviceInfo homeId:homeId success:^(TuyaSmartDeviceModel * _Nonnull deviceModel) {
                NSString *name = deviceModel.name?deviceModel.name:NSLocalizedString(@"Unknown Name", @"");
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Successfully Added", @"") ,name]];
                self.isSuccess = YES;
                [self.navigationController popViewControllerAnimated:YES];
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

- (void)stopConfigBLE {
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    
    [TuyaSmartBLEManager sharedInstance].delegate = nil;
    [[TuyaSmartBLEManager sharedInstance] stopListening:NO];
}

@end
