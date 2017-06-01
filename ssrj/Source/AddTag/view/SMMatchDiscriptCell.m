//
//  SMMatchDiscriptCell.m
//  ssrj
//
//  Created by MFD on 16/11/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDiscriptCell.h"
#import "Masonry.h"
@implementation SMMatchDiscriptCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _label = [[UILabel alloc]init];
        [self addSubview:_label];
        _label.font = [UIFont systemFontOfSize:15];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 20, 0, 0));
        }];
    }
    return self;
}

@end
