//
//  HHInforDraftCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforDraftCell.h"
#import "Masonry.h"
@interface HHInforDraftCell()
//封面
@property (nonatomic,strong)UIImageView *coverImageView;
//标题
@property (nonatomic,strong)UILabel *nameLabel;
//删除按钮
@property (nonatomic,strong)UIButton *deleteButton;
//遮盖
@property (nonatomic,strong)UIImageView *coverView;
@end
@implementation HHInforDraftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_coverImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:24];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _coverView = [[UIImageView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self addSubview:_coverView];
        
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:GetImage(@"match_redDel") forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        self.isShowDeleteBtn = NO;
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 1, 0));
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(25);
        }];
        
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.size.mas_equalTo(CGSizeMake(37, 37));
        }];
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_coverImageView);
        }];
    }
    return self;
}
- (void)deleteBtnClick {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}
- (void)setIsShowDeleteBtn:(BOOL)isShowDeleteBtn {
    _isShowDeleteBtn = isShowDeleteBtn;
    if (!_isShowDeleteBtn) {
        self.coverView.hidden = YES;
        self.deleteButton.hidden = YES;
    }else {
        self.coverView.hidden = NO;
        self.deleteButton.hidden = NO;
    }
}
- (void)setModel:(HHInforDraftModel *)model {
    _model = model;
    if (model.coverImageStyle.fileUrl.path.length) {
        _coverImageView.image = model.coverImageStyle.image;
    }else {
        _coverImageView.image = GetImage(@"640X360");
    }
    if (model.title.length) {
        _nameLabel.text = [NSString stringWithFormat:@"# %@ #",model.title];
    }
}
@end
