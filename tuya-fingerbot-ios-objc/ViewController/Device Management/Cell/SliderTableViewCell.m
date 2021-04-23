//
//  SliderTableViewCell.m
//  tuya-fingerbot-ios-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.slider) {
        [self.controls addObject:self.slider];
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (self.sliderAction) {
        self.sliderAction(sender);
    }
}


@end
