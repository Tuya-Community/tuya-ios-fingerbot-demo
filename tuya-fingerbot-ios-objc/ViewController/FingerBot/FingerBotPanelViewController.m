//
//  FingerBotPanelViewController.m
//  tuya-fingerbot-ios-objc_Example
//
//  Created by Gino on 2021/4/9.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "FingerBotPanelViewController.h"
#import "DeviceDetailTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import "SVProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface FingerBotPanelViewController () <TuyaSmartHomeDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) TuyaSmartHome *home;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UILabel *switchButtonLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UILabel *reValueLabel;

@property (strong, nonatomic) UIImageView *upImageView;
@property (strong, nonatomic) UILabel *upLabel;
@property (strong, nonatomic) UISlider *upSlider;

@property (strong, nonatomic) UIImageView *downImageView;
@property (strong, nonatomic) UILabel *downLabel;
@property (strong, nonatomic) UISlider *downSlider;

@property (strong, nonatomic) UIImageView *timeImageView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *timeValueLabel;
@property (strong, nonatomic) UIImageView *timeArrow;
@property (strong, nonatomic) UIView *timePickerBackgroundView;
@property (strong, nonatomic) UIPickerView *timePickerView;
@property (strong, nonatomic) NSMutableArray *timePickerDataSourceArray;

@property (strong, nonatomic) UIImageView *switchImageView;
@property (strong, nonatomic) UIImageView *reImageView;
@property (strong, nonatomic) UILabel *switchLabel;
@property (strong, nonatomic) UILabel *reLabel;
@property (strong, nonatomic) UISwitch *switchModeSwitch;
@property (strong, nonatomic) UIImageView *reArrow;

@property (assign, nonatomic) int minUp;
@property (assign, nonatomic) int maxUp;
@property (assign, nonatomic) int minDown;
@property (assign, nonatomic) int maxDown;
@property (assign, nonatomic) int minTime;
@property (assign, nonatomic) int maxTime;
@end

@implementation FingerBotPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([Home getCurrentHome]) {
        self.home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [self updateHomeDetail];
    }
    
    [self getRound];
    [self initView];
    [self reloadData];
}

- (void)getRound {
    for (TuyaSmartSchemaModel *model in self.device.deviceModel.schemaArray) {
        if ([model.dpId isEqualToString:@"15"]) {
            self.minUp = model.property.min;
            self.maxUp = model.property.max;
        } else if ([model.dpId isEqualToString:@"9"]) {
            self.minDown = model.property.min;
            self.maxDown = model.property.max;
        } else if ([model.dpId isEqualToString:@"10"]) {
            self.minTime = model.property.min;
            self.maxTime = model.property.max;
        }
    }
    self.timePickerDataSourceArray = [NSMutableArray new];
    for (int i = self.minTime; i<self.maxTime+1; i++) {
        [self.timePickerDataSourceArray addObject:[NSString stringWithFormat:@"%.1f", (float)i/10]];
    }
}

- (void)initView {
    [self.scrollView addSubview:self.infoView];
    [self.upView addSubview:self.upImageView];
    [self.upView addSubview:self.upLabel];
    [self.upView addSubview:self.upSlider];
    [self.downView addSubview:self.downImageView];
    [self.downView addSubview:self.downLabel];
    [self.downView addSubview:self.downSlider];
    
    [self.timeView addSubview:self.timeImageView];
    [self.timeView addSubview:self.timeLabel];
    [self.timeView addSubview:self.timeValueLabel];
    [self.timeView addSubview:self.timeArrow];
    
    [self.infoView addSubview:self.switchImageView];
    [self.infoView addSubview:self.reImageView];
    [self.infoView addSubview:self.switchLabel];
    [self.infoView addSubview:self.reLabel];
    [self.infoView addSubview:self.switchModeSwitch];
    [self.infoView addSubview:self.reValueLabel];
    [self.infoView addSubview:self.reArrow];
    
    [self.view addSubview:self.timePickerBackgroundView];
}

- (void)viewDidAppear:(BOOL)animated {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.infoView.frame.origin.y + 133 + 40);
}

- (void)reloadData {
    
    self.titleLabel.text = self.device.deviceModel.name;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@", [self.device.deviceModel.dps valueForKey:@"12"], @"%"];
    
    if ([[self.device.deviceModel.dps valueForKey:@"2"] intValue] == 0) {
        [self.switchButton.imageView setImage:[UIImage imageNamed:@"finger_bot_close"]];
        [self.switchButton setImage:[UIImage imageNamed:@"finger_bot_close"] forState:UIControlStateNormal];
        self.switchButtonLabel.text = NSLocalizedString(@"Enable", @"");
    } else {
        [self.switchButton.imageView setImage:[UIImage imageNamed:@"finger_bot_open"]];
        [self.switchButton setImage:[UIImage imageNamed:@"finger_bot_open"] forState:UIControlStateNormal];
        self.switchButtonLabel.text = NSLocalizedString(@"Disable", @"");
    }
    
    self.switchModeSwitch.on = [[self.device.deviceModel.dps valueForKey:@"8"] isEqualToString:@"switch"];
    
    self.reValueLabel.text = [[self.device.deviceModel.dps valueForKey:@"11"] isEqualToString:@"up_on"]?NSLocalizedString(@"Yes", @""):NSLocalizedString(@"No", @"");
    
    self.upLabel.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"Up · ", @"") ,[self.device.deviceModel.dps valueForKey:@"15"] ,@"%"];
    
    self.downLabel.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"Down · ", @"") ,[self.device.deviceModel.dps valueForKey:@"9"] ,@"%"];
    
    self.upSlider.value = [[self.device.deviceModel.dps valueForKey:@"15"] intValue];
    
    self.downSlider.value = [[self.device.deviceModel.dps valueForKey:@"9"] intValue];
    
    self.timeValueLabel.text = [NSString stringWithFormat:@"%.1f%@", [[self.device.deviceModel.dps valueForKey:@"10"] floatValue]/10.0 , NSLocalizedString(@"seconds", @"")];
    
    [self.timePickerView selectRow:[self.timePickerDataSourceArray indexOfObject:[NSString stringWithFormat:@"%.1f", [[self.device.deviceModel.dps valueForKey:@"10"] floatValue]/10.0]] inComponent:0 animated:NO];
    
    if (self.switchModeSwitch.isOn == YES) {
        self.infoView.frame = CGRectMake(self.infoView.frame.origin.x, self.infoView.frame.origin.y, self.view.frame.size.width - 16, 133);
    } else {
        self.infoView.frame = CGRectMake(self.infoView.frame.origin.x, self.infoView.frame.origin.y, self.view.frame.size.width - 16, 74);
    }
}

- (void)updateHomeDetail {
    [self.home getHomeDetailWithSuccess:^(TuyaSmartHomeModel *homeModel) {

    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to get the home.", @"") message:error.localizedDescription];
    }];
}

- (IBAction)backButtonTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)editButtonTouchUpInside:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceList" bundle:nil];
    DeviceDetailTableViewController *deviceDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"DeviceDetailTableViewController"];
    deviceDetailVC.device = self.device;
    [self.navigationController pushViewController:deviceDetailVC animated:YES];
}

- (IBAction)switchButtonTouched:(id)sender {
    [self.device publishDps:@{@"2": [[self.device.deviceModel.dps valueForKey:@"2"] intValue] == 1?[NSNumber numberWithBool:NO]:[NSNumber numberWithBool:YES]} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [UIView new];
        _infoView.frame = CGRectMake(self.timeView.frame.origin.x, self.timeView.frame.origin.y + 8 + self.timeView.frame.size.height, self.view.frame.size.width - 16, 74);
        _infoView.backgroundColor = [UIColor whiteColor];
        _infoView.layer.cornerRadius = 14.f;
        _infoView.layer.masksToBounds = YES;
    }
    return _infoView;
}

- (UILabel *)reValueLabel {
    if (!_reValueLabel) {
        _reValueLabel = [UILabel new];
        _reValueLabel.frame = CGRectMake(self.view.frame.size.width - 16 - 36 - 150, 84, 150, 24);
        _reValueLabel.textAlignment = NSTextAlignmentRight;
        _reValueLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _reValueLabel.font = [UIFont systemFontOfSize:15];
        _reValueLabel.text = [[self.device.deviceModel.dps valueForKey:@"11"] isEqualToString:@"up_on"]?NSLocalizedString(@"Yes", @""):NSLocalizedString(@"No", @"");
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reLabelTaped:)];
        _reValueLabel.userInteractionEnabled = YES;
        _reValueLabel.alpha = 0.5;
        [_reValueLabel addGestureRecognizer:tapGesture];
    }
    return _reValueLabel;
}

- (void)reLabelTaped:(UITapGestureRecognizer *)gesture
{
    [self.device publishDps:@{@"11": [[self.device.deviceModel.dps valueForKey:@"11"] isEqualToString:@"up_on"]?@"up_off":@"up_on"} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (UIImageView *)upImageView {
    if (!_upImageView) {
        _upImageView = [UIImageView new];
        _upImageView.frame = CGRectMake(22, 33, 12, 6);
        _upImageView.image = [UIImage imageNamed:@"finger_bot_arrow_up"];
    }
    return _upImageView;
}

- (UIImageView *)downImageView {
    if (!_downImageView) {
        _downImageView = [UIImageView new];
        _downImageView.frame = CGRectMake(22, 33, 12, 6);
        _downImageView.image = [UIImage imageNamed:@"finger_bot_arrow_down"];
    }
    return _downImageView;
}

- (UILabel *)upLabel {
    if (!_upLabel) {
        _upLabel = [UILabel new];
        _upLabel.frame = CGRectMake(48, 24, 150, 24);
        _upLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _upLabel.font = [UIFont systemFontOfSize:15];
        _upLabel.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"Up · ", @"") ,[self.device.deviceModel.dps valueForKey:@"15"] ,@"%"];
    }
    return _upLabel;
}

- (UILabel *)downLabel {
    if (!_downLabel) {
        _downLabel = [UILabel new];
        _downLabel.frame = CGRectMake(48, 24, 150, 24);
        _downLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _downLabel.font = [UIFont systemFontOfSize:15];
        _downLabel.text = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"Down · ", @"") ,[self.device.deviceModel.dps valueForKey:@"9"] ,@"%"];
    }
    return _downLabel;
}

- (UISlider *)upSlider {
    if (!_upSlider) {
        _upSlider = [UISlider new];
        _upSlider.minimumValue = 0;
        _upSlider.maximumValue = 100;
        _upSlider.minimumValueImage = [UIImage imageNamed:@"finger_bot_slider_min"];
        _upSlider.maximumValueImage = [UIImage imageNamed:@"finger_bot_slider_max"];
        _upSlider.frame = CGRectMake(25, 72, self.view.frame.size.width - 16 - 50, 40);
        _upSlider.value = [[self.device.deviceModel.dps valueForKey:@"15"] intValue];
        [_upSlider addTarget:self action:@selector(upSliderValue:) forControlEvents:UIControlEventValueChanged];
        [_upSlider addTarget:self action:@selector(upSliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _upSlider;
}

-(void)upSliderValue:(id)sender{
    if (self.upSlider.value >= self.maxUp) {
        self.upSlider.value = self.maxUp;
    } else if (self.upSlider.value <= self.minUp) {
        self.upSlider.value = self.minUp;
    }
    _upLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"Up · ", @"") , (int)self.upSlider.value ,@"%"];
}

-(void)upSliderValueEnd:(id)sender{
    if (self.upSlider.value >= self.maxUp) {
        self.upSlider.value = self.maxUp;
    } else if (self.upSlider.value <= self.minUp) {
        self.upSlider.value = self.minUp;
    }
    _upLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"Up · ", @"") , (int)self.upSlider.value ,@"%"];
    [self.device publishDps:@{@"15": [NSNumber numberWithInt:(int)self.upSlider.value]} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (UISlider *)downSlider {
    if (!_downSlider) {
        _downSlider = [UISlider new];
        _downSlider.minimumValue = 0;
        _downSlider.maximumValue = 100;
        _downSlider.minimumValueImage = [UIImage imageNamed:@"finger_bot_slider_min"];
        _downSlider.maximumValueImage = [UIImage imageNamed:@"finger_bot_slider_max"];
        _downSlider.frame = CGRectMake(25, 72, self.view.frame.size.width - 16 - 50, 40);
        _downSlider.value = [[self.device.deviceModel.dps valueForKey:@"9"] intValue];
        [_downSlider addTarget:self action:@selector(downSliderValue:) forControlEvents:UIControlEventValueChanged];
        [_downSlider addTarget:self action:@selector(downSliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downSlider;
}

-(void)downSliderValue:(id)sender{
    if (self.downSlider.value >= self.maxDown) {
        self.downSlider.value = self.maxDown;
    } else if (self.downSlider.value <= self.minDown) {
        self.downSlider.value = self.minDown;
    }
    _downLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"Down · ", @"") , (int)self.downSlider.value ,@"%"];
}

-(void)downSliderValueEnd:(id)sender{
    if (self.downSlider.value >= self.maxDown) {
        self.downSlider.value = self.maxDown;
    } else if (self.downSlider.value <= self.minDown) {
        self.downSlider.value = self.minDown;
    }
    _downLabel.text = [NSString stringWithFormat:@"%@%d%@",NSLocalizedString(@"Down · ", @"") , (int)self.downSlider.value ,@"%"];
    [self.device publishDps:@{@"9": [NSNumber numberWithInt:(int)self.downSlider.value]} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (UIImageView *)timeImageView {
    if (!_timeImageView) {
        _timeImageView = [UIImageView new];
        _timeImageView.frame = CGRectMake(21, 30, 14, 14);
        _timeImageView.image = [UIImage imageNamed:@"finger_bot_time"];
    }
    return _timeImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.frame = CGRectMake(48, 24, 150, 24);
        _timeLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.text = NSLocalizedString(@"Duration", @"");
    }
    return _timeLabel;
}

- (UILabel *)timeValueLabel {
    if (!_timeValueLabel) {
        _timeValueLabel = [UILabel new];
        _timeValueLabel.frame = CGRectMake(self.view.frame.size.width - 16 - 36 - 100, 24, 100, 24);
        _timeValueLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _timeValueLabel.font = [UIFont systemFontOfSize:15];
        _timeValueLabel.alpha = 0.5;
        _timeValueLabel.textAlignment = NSTextAlignmentRight;
        _timeValueLabel.text = [NSString stringWithFormat:@"%.1f%@", [[self.device.deviceModel.dps valueForKey:@"10"] floatValue]/10.0 , NSLocalizedString(@"seconds", @"")];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeValueLabelTaped:)];
        _timeValueLabel.userInteractionEnabled = YES;
        [_timeValueLabel addGestureRecognizer:tapGesture];
    }
    return _timeValueLabel;
}

- (void)timeValueLabelTaped:(UITapGestureRecognizer *)gesture
{
    _timePickerBackgroundView.hidden = NO;
}

- (UIImageView *)timeArrow {
    if (!_timeArrow) {
        _timeArrow = [UIImageView new];
        _timeArrow.frame = CGRectMake(self.view.frame.size.width - 16 - 21 - 4.5, 31, 4.5, 10);
        _timeArrow.image = [UIImage imageNamed:@"finger_bot_arrow_light"];
    }
    return _timeArrow;
}

- (UIView *)timePickerBackgroundView {
    if (!_timePickerBackgroundView) {
        _timePickerBackgroundView = [UIView new];
        _timePickerBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _timePickerBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _timePickerBackgroundView.hidden = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timePickerTaped:)];
        _timePickerBackgroundView.userInteractionEnabled = YES;
        [_timePickerBackgroundView addGestureRecognizer:tapGesture];
        [_timePickerBackgroundView addSubview:self.timePickerView];
    }
    return _timePickerBackgroundView;
}

- (void)timePickerTaped:(UITapGestureRecognizer *)gesture
{
    _timePickerBackgroundView.hidden = YES;
}

- (UIImageView *)switchImageView {
    if (!_switchImageView) {
        _switchImageView = [UIImageView new];
        _switchImageView.frame = CGRectMake(21, 30, 14, 14);
        _switchImageView.image = [UIImage imageNamed:@"finger_bot_switch_mode"];
    }
    return _switchImageView;
}

- (UIImageView *)reImageView {
    if (!_reImageView) {
        _reImageView = [UIImageView new];
        _reImageView.frame = CGRectMake(24, 88, 8, 16);
        _reImageView.image = [UIImage imageNamed:@"finger_bot_re_mode"];
    }
    return _reImageView;
}

- (UILabel *)switchLabel {
    if (!_switchLabel) {
        _switchLabel = [UILabel new];
        _switchLabel.frame = CGRectMake(48, 25, 150, 24);
        _switchLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _switchLabel.font = [UIFont systemFontOfSize:15];
        _switchLabel.text = NSLocalizedString(@"Switch Mode", @"");
    }
    return _switchLabel;
}


- (UILabel *)reLabel {
    if (!_reLabel) {
        _reLabel = [UILabel new];
        _reLabel.frame = CGRectMake(45, 84, 150, 24);
        _reLabel.textColor = UIColorFromRGB(0x3d3d3d);
        _reLabel.font = [UIFont systemFontOfSize:15];
        _reLabel.text = NSLocalizedString(@"Reverse", @"");
    }
    return _reLabel;
}

- (UISwitch *)switchModeSwitch {
    if (!_switchModeSwitch) {
        _switchModeSwitch = [UISwitch new];
        _switchModeSwitch.frame = CGRectMake(self.view.frame.size.width - 16 - 30 - 40, 25, 40, 24);
        _switchModeSwitch.onTintColor = UIColorFromRGB(0x63a8fc);
        [_switchModeSwitch addTarget:self action:@selector(switchModeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchModeSwitch;
}

- (void)switchModeAction:(UISwitch *)s {
    [self.device publishDps:@{@"8": [[self.device.deviceModel.dps valueForKey:@"8"] isEqualToString:@"switch"]?@"click":@"switch"} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (UIImageView *)reArrow {
    if (!_reArrow) {
        _reArrow = [UIImageView new];
        _reArrow.frame = CGRectMake(self.view.frame.size.width - 16 - 21 - 4.5, 91, 4.5, 10);
        _reArrow.image = [UIImage imageNamed:@"finger_bot_arrow_light"];
    }
    return _reArrow;
}

- (UIPickerView *)timePickerView {
    if (!_timePickerView) {
        CGRect frame = CGRectMake(0, self.view.frame.size.height-300, self.view.frame.size.width, 300);
        _timePickerView = [[UIPickerView alloc] initWithFrame:frame];
        _timePickerView.backgroundColor = [UIColor whiteColor];
        _timePickerView.dataSource = self;
        _timePickerView.delegate = self;
    }
    return _timePickerView;
}

#pragma mark - UIPickerViewDataSource

// 返回需要展示的列（columns）的数目
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// 返回每一列的行（rows）数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timePickerDataSourceArray.count;
}

#pragma mark - UIPickerViewDelegate

// 返回每一行的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.timePickerDataSourceArray[row];
}

// 某一行被选择时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *item = self.timePickerDataSourceArray[row];
    [self.device publishDps:@{@"10": [NSNumber numberWithFloat:[item floatValue]*10]} success:^{

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

-(void)home:(TuyaSmartHome *)home device:(TuyaSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    if ([self.device.deviceModel.devId isEqualToString:device.devId]) {
        self.device.deviceModel.dps = device.dps;
        [self reloadData];
    }
}
@end
