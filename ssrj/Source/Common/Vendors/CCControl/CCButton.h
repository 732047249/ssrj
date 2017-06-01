//
//  CCButton.h
//  FiveTV
//
//  Created by CC on 15/4/1.
//  Copyright (c) 2015年 Beijing Xiuke Entertainment Tech Limited All rights reserved.
//

#import "CCControl.h"

@interface CCButton : CCControl
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *agentButton;


@property (strong, nonatomic) UIImageView *strong_icon;
@property (strong, nonatomic) UILabel *strong_titleLabel;
@property (strong, nonatomic) UIButton *strong_agentButton;

@property (strong, nonatomic) NSIndexPath * selectIndexPath;
@property (copy, nonatomic) void (^highlightEffectBlock)(CCButton *sender);
@property (copy, nonatomic) void (^unhighlightEffectBlock)(CCButton *sender);
@property (copy, nonatomic) void (^selecteEffectBlock)(CCButton *sender);
@property (copy, nonatomic) void (^unselecteEffectBlock)(CCButton *sender);

@property (copy, nonatomic, setter = setTappedBlock:) void (^tappedBlock)(CCButton *) DEPRECATED_ATTRIBUTE;
@end
