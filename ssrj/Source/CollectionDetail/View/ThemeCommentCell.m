//
//  ThemeCommentCell.m
//  ssrj
//
//  Created by MFD on 16/9/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeCommentCell.h"
#import <Masonry.h>
#import "NSAttributedString+YYText.h"

@implementation ThemeCommentCell
{
    BOOL _trackingTouch;
    BOOL _touchComment;
}


- (void)setYyLabelLayoutModel:(YYLabelLayoutModel *)yyLabelLayoutModel{
    _yyLabelLayoutModel = yyLabelLayoutModel;
    YYTextLayout *layout = yyLabelLayoutModel.textLayout;
    self.commentLabel.textLayout = layout;
    self.commentLabel.size = layout.textBoundingSize;
    
    
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
//        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
    }];
    
    
    [self.commentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_icon.mas_right).offset(10);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [self.authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_commentView.mas_left);
        make.top.equalTo(_commentView.mas_top).offset(10);
    }];
    
    [self.commentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_commentView.mas_left);
        make.top.equalTo(_authorLabel.mas_bottom).offset(10);
        make.right.equalTo(_commentView.mas_right).offset(-15);
        make.height.mas_equalTo(_yyLabelLayoutModel.textLayout.textBoundingSize.height);
    }];
    
    [self.dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_commentView.mas_left);
        make.top.equalTo(_commentLabel.mas_bottom).offset(10);
    }];
    
    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateLabel.mas_right).offset(10);
        make.centerY.equalTo(_dateLabel.mas_centerY);
    }];
    
    [self.sepLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateLabel.mas_bottom).offset(10);
        make.left.equalTo(_commentView.mas_left);
        make.right.equalTo(_commentView.mas_right);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    
    
}


- (void)setCommentListModel:(CommentListModel *)commentListModel{
    _commentListModel = commentListModel;
    [_icon sd_setImageWithURL:[NSURL URLWithString:commentListModel.member.avatar] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    
    //可能存在没有用户名的情况
    if (commentListModel.member.name.length == 0) {
        
        _authorLabel.text = @"未知";
    }
    else {
        
        _authorLabel.text = commentListModel.member.name;
    }
    
    //    _commentLabel.text = commentListModel.comment;
    _dateLabel.text = commentListModel.createDate;
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    if (1 == commentListModel.isActiveUser.integerValue) {
        _deleteButton.hidden = NO;
    }else{
        _deleteButton.hidden = YES;
    }
    
    
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:commentListModel.comment];
//    
//    
//    NSArray *atResults = [[self regex_At] matchesInString:text.string options:kNilOptions range:text.yy_rangeOfAll];
//    
//    for (NSTextCheckingResult *at in atResults) {
//        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
//        if ([text yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
//            [text yy_setColor:[UIColor colorWithHexString:@"1b82bd"] range:at.range];
//            
//            YYTextHighlight *highlight = [YYTextHighlight new];
////            highlight.userInfo = @{@"name":[text.string substringWithRange:(NSMakeRange(at.range.location + 1, at.range.length - 1))]};
//            if (commentListModel.replyMember.memberId) {
//                highlight.userInfo = @{@"memberId":commentListModel.replyMember.memberId};
//            }
//            [text yy_setTextHighlight:highlight range:at.range];
//        }
//    }
//    _commentLabel.attributedText = text;
}


//- (NSRegularExpression *)regex_At{
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5].*:" options:kNilOptions error:NULL];
//    return regex;
//}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.commentView];
        
        [self.commentView addSubview:self.authorLabel];
        [self.commentView addSubview:self.commentLabel];
        [self.commentView addSubview:self.dateLabel];
        [self.commentView addSubview:self.deleteButton];
        [self.commentView addSubview:self.sepLine];
        
//        _icon = [[UIImageView alloc]initWithFrame:CGRectZero];
//        _icon.layer.cornerRadius = 17;
//        _icon.layer.masksToBounds = YES;
//        _commentView = [[UIView alloc]initWithFrame:CGRectZero];
//        [self.contentView addSubview:_icon];
//        [self.contentView addSubview:_commentView];
//        
//        
//        _authorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        _authorLabel.font = [UIFont systemFontOfSize:12];
//        _commentLabel = [YYLabel new];
//        _commentLabel.numberOfLines = 0;
//        _commentLabel.font = [UIFont systemFontOfSize:12];
//        //        _commentLabel.displaysAsynchronously = YES;
//        _commentLabel.fadeOnAsynchronouslyDisplay = YES;
//        //        _commentLabel.fadeOnHighlight = NO;
//        __weak __typeof(&*self)weakSelf = self;
//        
//        //        _commentLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
//        //            if ([weakSelf.delegate respondsToSelector:@selector(celldidClickLabel:textRange:)]) {
//        //                [weakSelf.delegate celldidClickLabel:weakSelf.commentLabel textRange:range];
//        //            }
//        //        };
//        
//        
//        _commentLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
//            if ([weakSelf.delegate respondsToSelector:@selector(celldidClickLabel:textRange:indexPath:)]) {
//                [weakSelf.delegate celldidClickLabel:weakSelf.commentLabel textRange:range indexPath:weakSelf.indexPath];
//            }
//        };
//        
//        
//        _dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        _dateLabel.font = [UIFont systemFontOfSize:12];
//        _deleteButton = [[UIButton alloc]initWithFrame:CGRectZero];
//        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
//        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
//        _deleteButton.hidden = YES;
//        _sepLine = [[UIView alloc]initWithFrame:CGRectZero];
//        _sepLine.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
//        [_commentView addSubview:_authorLabel];
//        [_commentView addSubview:_commentLabel];
//        [_commentView addSubview:_dateLabel];
//        [_commentView addSubview:_deleteButton];
//        [_commentView addSubview:_sepLine];
//        
//        
//        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView.mas_left).offset(10);
//            make.centerY.equalTo(self.contentView.mas_centerY);
//            make.width.mas_equalTo(34);
//            make.height.mas_equalTo(34);
//        }];
//        
//        [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_icon.mas_right).offset(10);
//            make.top.equalTo(self.contentView.mas_top);
//            make.bottom.equalTo(self.contentView.mas_bottom);
//            make.right.equalTo(self.contentView.mas_right);
//        }];
//        
//        [_authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_commentView.mas_left);
//            make.top.equalTo(_commentView.mas_top).offset(10);
//        }];
//        
//        [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_commentView.mas_left);
//            make.top.equalTo(_authorLabel.mas_bottom).offset(10);
//            make.right.equalTo(_commentView.mas_right).offset(-15);
//        }];
//        
//        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_commentView.mas_left);
//            make.top.equalTo(_commentLabel.mas_bottom).offset(10);
//        }];
//        
//        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_dateLabel.mas_right).offset(10);
//            make.centerY.equalTo(_dateLabel.mas_centerY);
//        }];
//        
//        [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_dateLabel.mas_bottom).offset(10);
//            make.left.equalTo(_commentView.mas_left);
//            make.right.equalTo(_commentView.mas_right);
//            make.height.mas_equalTo(1);
//            make.bottom.equalTo(self.contentView.mas_bottom);
//        }];
    }
    return self;
}


- (UIImageView *)icon{
    if (_icon == nil) {
        _icon = [[UIImageView alloc]initWithFrame:CGRectZero];
        _icon.layer.cornerRadius = 17;
        _icon.layer.masksToBounds = YES;
    }
    return _icon;
}

- (UIView *)commentView{
    if (_commentView == nil) {
        _commentView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _commentView;
}

- (UILabel *)authorLabel{
    if (_authorLabel == nil) {
        _authorLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _authorLabel.font = [UIFont systemFontOfSize:12];
    }
    return _authorLabel;
}


- (YYLabel *)commentLabel{
    if (_commentLabel == nil) {
        _commentLabel = [[YYLabel alloc]initWithFrame:CGRectZero];
        _commentLabel.numberOfLines = 0;
        UIFont *font = [UIFont systemFontOfSize:12];
        _commentLabel.font = font;
        _commentLabel.displaysAsynchronously = YES;
        _commentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        __weak __typeof(&*self)weakSelf = self;
        _commentLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
            if ([weakSelf.delegate respondsToSelector:@selector(celldidClickLabel:textRange:indexPath:)]) {
                [weakSelf.delegate celldidClickLabel:weakSelf.commentLabel textRange:range indexPath:weakSelf.indexPath];
            }
        };
    }
    return _commentLabel;
}


- (UILabel *)dateLabel{
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.textColor = [UIColor colorWithHexString:@"898e90"];
    }
    return _dateLabel;
}


- (UIButton *)deleteButton{
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"898e90"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

- (UIView *)sepLine{
    if (_sepLine == nil) {
        _sepLine = [[UIView alloc]initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
    }
    return _sepLine;
}







- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch = NO;
    UITouch *t = touches.anyObject;
    CGPoint p = [t locationInView:_icon];
    if (CGRectContainsPoint(_icon.bounds, p)) {
        _trackingTouch = YES;
    }
    
    if (CGRectContainsPoint(_commentLabel.bounds, p)) {
        _touchComment = YES;
    }
    
    
    
    if (!_trackingTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch) {
        [super touchesEnded:touches withEvent:event];
    }else{
        if ([self.delegate respondsToSelector:@selector(celldidClickUser:)]) {
            [self.delegate celldidClickUser:self.commentListModel];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch) {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)prepareForReuse{
    _icon.image = nil;
    
    _authorLabel.text = nil;
    
    _commentLabel.text = nil;
    
    _dateLabel.text = nil;
}

@end
