//
//  HHInformationTextView.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInformationTextView.h"
#import "UIButton+ImageTitleSpacing.h"
#import "UIFont+LMText.h"
#import "HHTextAttachment.h"
static CGFloat const kHHCommonSpacing = 16.f;

static NSString * const GrayColor = @"#e5e5e5";
@implementation HHInformationTextView{
    
    UIView *_containerView;
    UIView *_separatorLineOne;
    UIView *_separatorLineTwo;
    
}
#pragma mark - 设置光标的长度
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    
    /**
     文字光标长度设置
     */
    UIFont *font = self.typingAttributes[NSFontAttributeName];
    originalRect.size.height = font.fontSize + 4;
    originalRect.size.width = 2;
    
    /**
     图片光标长度设置
     */
    if (self.selectedRange.location > 0) {
        NSAttributedString *attributeString = [self.attributedText attributedSubstringFromRange:NSMakeRange(self.selectedRange.location - 1, 1)];
        NSRange effectiveRange = NSMakeRange(0, 1);
        HHTextAttachment *attachment = (HHTextAttachment *)[attributeString attributesAtIndex:0 effectiveRange:&effectiveRange][NSAttachmentAttributeName];
        if (attachment && [attachment isKindOfClass:[HHTextAttachment class]]) {
            originalRect.size.height = attachment.imageStyle.size.height + 4;
        }
    }
    
    return originalRect;
}
- (BOOL)checkIsImage {
    NSRange range = self.selectedRange;
    
    if (range.location == 0) {
        return NO;
    }
    NSAttributedString *attributeString = [self.attributedText attributedSubstringFromRange:NSMakeRange(range.location - 1, 1)];
    NSRange effectiveRange = NSMakeRange(0, 1);
    
    NSTextAttachment *attachment = [attributeString attributesAtIndex:0 effectiveRange:&effectiveRange][NSAttachmentAttributeName];
    if (attachment) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    
    
    _containerView = [[UIView alloc] init];
    [self addSubview:_containerView];
    
    //添加封面图片
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_coverImageView setImage:GetImage(@"infor_addbg")];
    _coverImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [_coverImageView addGestureRecognizer:tap];
    
    //封面图片下的线
    _separatorLineOne = [[UIView alloc] init];
    _separatorLineOne.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    //选择专题按钮
    _selectSpecialTopicBtn = [[HHMenuPullButton alloc] init];
    _selectSpecialTopicBtn.nameLabel.text = @"选择专题";
    _selectSpecialTopicBtn.nameLabel.textColor = [UIColor colorWithHexString:GrayColor];
    _selectSpecialTopicBtn.nameLabel.font = [UIFont systemFontOfSize:14];
    _selectSpecialTopicBtn.imageName = @"infor_down_0";
    _selectSpecialTopicBtn.clipsToBounds = YES;
    _selectSpecialTopicBtn.layer.borderColor = [UIColor colorWithHexString:GrayColor].CGColor;
    _selectSpecialTopicBtn.layer.borderWidth = 1;
    
    //标题
    _titleTextField = [[UITextField alloc] init];
    _titleTextField.font = [UIFont boldSystemFontOfSize:18.f];
    _titleTextField.placeholder = @"请输入标题";
    
    //标题和正文分割线
    _separatorLineTwo = [[UIView alloc] init];
    _separatorLineTwo.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    [_containerView addSubview:_coverImageView];
    [_containerView addSubview:_selectSpecialTopicBtn];
    [_containerView addSubview:_titleTextField];
    [_containerView addSubview:_separatorLineOne];
    [_containerView addSubview:_separatorLineTwo];
    
    self.autocorrectionType = UITextAutocorrectionTypeNo;//自动纠错NO
    self.spellCheckingType = UITextSpellCheckingTypeNo;//检查拼写NO
    self.alwaysBounceVertical = YES;//允许有弹性效果Yes
    self.layoutManager.allowsNonContiguousLayout = NO;//是否非连续布局，自己重置滑动.解决跳动问题
    //设置文本输入区域 默认{8, 0, 8, 0} 修改后 {316, 16, 16, 16}
    self.textContainerInset = UIEdgeInsetsMake(kScreenWidth / 16.0 * 9 + 100 + kHHCommonSpacing,
                                               kHHCommonSpacing - 5,
                                               kHHCommonSpacing,
                                               kHHCommonSpacing - 5);
    [self setRect];
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHHCommonSpacing + 1, kScreenWidth / 16.0 * 9 + 100 + kHHCommonSpacing, 100, 15)];
    _placeholderLabel.font = [UIFont systemFontOfSize:14];
    _placeholderLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _placeholderLabel.text = @"请输入正文";
    [self addSubview:_placeholderLabel];
}
- (void)setRect {
    
    //容器高度： 200 * screen.scale (图片高度) + 100 (标题和选择专题)
    _containerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth / 16.0 * 9 + 100);
    _coverImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth / 16.0 * 9);
    _separatorLineOne.frame = CGRectMake(0, CGRectGetMaxY(_coverImageView.frame), kScreenWidth, 1);
    _selectSpecialTopicBtn.frame = CGRectMake(kHHCommonSpacing, CGRectGetMaxY(_separatorLineOne.frame) + kHHCommonSpacing, 120, 30);
    _selectSpecialTopicBtn.layer.cornerRadius = _selectSpecialTopicBtn.bounds.size.height * 0.5;
    [_selectSpecialTopicBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:3];
    _titleTextField.frame = CGRectMake(kHHCommonSpacing, CGRectGetMaxY(_selectSpecialTopicBtn.frame) + kHHCommonSpacing - 3, kScreenWidth - 2 * kHHCommonSpacing, 25);
    _separatorLineTwo.frame = CGRectMake(kHHCommonSpacing, CGRectGetHeight(_containerView.frame) - 1, kScreenWidth - 2 * kHHCommonSpacing, 1);
}


#pragma mark - event 
- (void)tapHandle:(UITapGestureRecognizer *)tap {
    if (self.clickCoverDelegate && [self.delegate respondsToSelector:@selector(informationTextView:didClickCover:)]) {
        [self.clickCoverDelegate informationTextView:self didClickCover:_coverImageView];
    }
}
- (void)deleteAllContent {
    
    self.coverImageView.image = GetImage(@"infor_addbg");
    self.attributedText = nil;
    self.titleTextField.text = @"";
    _placeholderLabel.hidden = NO;
    _selectSpecialTopicBtn.nameLabel.text = @"选择专题";
    _selectSpecialTopicBtn.nameLabel.textColor = [UIColor colorWithHexString:GrayColor];
    _selectSpecialTopicBtn.nameLabel.font = [UIFont systemFontOfSize:14];
    _selectSpecialTopicBtn.imageName = @"infor_down_0";
    _selectSpecialTopicBtn.layer.borderWidth = 1;
    _selectSpecialTopicBtn.frame = CGRectMake(kHHCommonSpacing, CGRectGetMaxY(_separatorLineOne.frame) + kHHCommonSpacing, 120, 30);
    _selectSpecialTopicBtn.backgroundColor = [UIColor whiteColor];
    [_selectSpecialTopicBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:3];
}
@end
