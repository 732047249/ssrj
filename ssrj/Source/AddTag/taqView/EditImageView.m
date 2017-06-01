//
//  EditImageView.m
//  20161101
//
//  Created by MFD on 16/11/1.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "EditImageView.h"
@interface EditImageView()

/** 承载tagView */
@property (nonatomic,strong)UIView *containerView;

@end
#define KTagViewHeight 25
#define KTagFont 14
#define KPage 40
@implementation EditImageView
{
    TagView *cutView;
}
//用于显示标签
- (void)awakeFromNib {
    [super awakeFromNib];
    [self configParams];
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    _containerView = [[UIView alloc] init];
    [self addSubview:_containerView];
}
// 用于上传图片
+ (instancetype)editViewWithFrame:(CGRect)frame {
    EditImageView *editView = [[self alloc]initWithFrame:frame];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:editView action:@selector(didTapContainerView:)];
    [editView.containerView addGestureRecognizer:tap];
    editView.allowLongPressDeleteTagView = YES;
    return editView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configParams];
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        _containerView = [[UIView alloc] init];
        [self addSubview:self.containerView];
    }
    return self;
}
- (void)configParams {
    self.allowLongPressDeleteTagView = NO;
    self.allowTapBgHiddenTagView = NO;
    self.allowTapTagView = YES;
}
- (void)addTagWithModel:(TagModel *)model {
    //去重
    for (TagView *existTag in self.tagViewArray) {
        if ([model.goodsId isEqualToString:existTag.model.goodsId] && model.goodsId) {
            return;
        }
    }
    TagView *tagView = [[TagView alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
    [self.containerView addSubview:tagView];
    tagView.model = model;
    [self.tagViewArray addObject:tagView];
    if (self.allowTapTagView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTagView:)];
        [tagView addGestureRecognizer:tap];
    }
    if (self.allowLongPressDeleteTagView) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPresssTagView:)];
        [tagView addGestureRecognizer:longPress];
        tagView.allowSwitchDirection = YES;
    }else {
        tagView.allowSwitchDirection = NO;
        tagView.allowPan = NO;
    }
}
- (void)deleteAllTagView {
    [self.containerView removeSubviews];
    [self.tagViewArray removeAllObjects];
}
//添加pc标签
- (void)addTagViewToPCCollocationWithPositionArray:(NSArray<HHPCCollocationPositionModel *> *)positionArray goodsList:(NSArray<RJBaseGoodModel *> *)goodsList{
    
    if (!positionArray || !goodsList || !positionArray.count || !goodsList.count) {
        return;
    }
    
    for (int i = 0; i < goodsList.count; i++) {
        RJBaseGoodModel *goodsModel = goodsList[i];
        HHPCCollocationPositionModel *positionModel;
        for (HHPCCollocationPositionModel *tempModel in positionArray) {
            if (goodsModel.goodId && [tempModel.goodsId isEqualToString:goodsModel.goodId]) {
                positionModel = tempModel;
            }
        }
        if (!positionModel) {
            continue;
        }

        CGFloat orignalCenterX = [positionModel.left floatValue] + [positionModel.width floatValue] * 0.5;
        CGFloat orignalCenterY = [positionModel.top floatValue] + [positionModel.height floatValue] * 0.5;
        CGFloat scale = self.bounds.size.width / 600;
        
        TagModel *model = [[TagModel alloc] init];
        model.point = CGPointMake(orignalCenterX * scale, orignalCenterY * scale);
        model.tagText = [NSString stringWithFormat:@"%@ ¥%@",goodsModel.name,goodsModel.effectivePrice];
        model.goodsId = goodsModel.goodId;
        [self addTagWithModel:model];
    }
    
    self.containerView.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
        self.containerView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

//上传照片 标签
- (void)addTagViewToPictureWithDraftString:(NSString *)string goodsList:(NSArray<RJBaseGoodModel *> *)goodsList {
    if (!string.length) return;
    NSError *error;
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!dic[@"data"] || ![dic[@"data"] count]) {
        return;
    }
    
    for (NSDictionary *tagDic in dic[@"data"]) {
        if (!error) {
            CGFloat pointX = [tagDic[@"pointX"] floatValue];
            CGFloat pointY = [tagDic[@"pointY"] floatValue];
            int direction = [tagDic[@"direction"] intValue];
            CGFloat screenWidth = [tagDic[@"screenWidth"] floatValue];
            NSString *tagText = tagDic[@"tagText"];
            //kScreenWidth 要换成现在
            CGFloat scale = self.width / screenWidth;
            
            TagModel *model = [[TagModel alloc] init];
            model.point = CGPointMake(pointX * scale, pointY * scale);
            model.tagText = tagText;
            model.direction = direction;
            
            if (tagDic[@"id"]) {
                RJBaseGoodModel *goodsModel = nil;
                for (RJBaseGoodModel *tempModel in goodsList) {
                    if ([tempModel.goodId isEqualToString:tagDic[@"id"]]) {
                        goodsModel = tempModel;
                    }
                }
                if (!goodsModel) {
                    continue;
                }
                model.goodsId = goodsModel.goodId;
                model.tagText = [NSString stringWithFormat:@"%@ ¥%@",goodsModel.name,goodsModel.effectivePrice];
            }
            
            [self addTagWithModel:model];
        }
    }
    self.containerView.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
        self.containerView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
//在线创作
- (void)addTagViewToCollocationWithDraftString:(NSString *)string goodsList:(NSArray<RJBaseGoodModel *> *)goodsList{
    if (!string.length) return;
    NSError *error;
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return;
    }
    
    NSArray *arr = dic[@"data"];
    if (!arr || !goodsList || !arr.count || !goodsList.count) {
        return;
    }
    
    for (int i = 0; i < goodsList.count; i++) {
        RJBaseGoodModel *goodsModel = goodsList[i];
        NSDictionary *tagDict = nil;
        for (NSDictionary *dic in arr) {
            if (goodsModel.goodId && [goodsModel.goodId isEqualToString:dic[@"id"]]) {
                tagDict = dic;
            }
        }
        if (!tagDict) {
            continue;
        }

        CGPoint center = CGPointFromString(tagDict[@"center"]);
        CGFloat screenWidth = [tagDict[@"screenWidth"] floatValue];
        //kScreenWidth 要换成现在
        CGFloat scale = self.width / screenWidth;
        
        TagModel *model = [[TagModel alloc] init];
        model.point = CGPointMake(center.x * scale, center.y * scale);
        model.tagText = [NSString stringWithFormat:@"%@ ¥%@",goodsModel.name,goodsModel.effectivePrice];
        model.goodsId = goodsModel.goodId;
        [self addTagWithModel:model];
    }
    self.containerView.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
        self.containerView.alpha = 1;
    } completion:^(BOOL finished) {
    }];

}
#pragma mark - event
/** 点击容器，来添加标签 */
- (void)didTapContainerView:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:recognizer.view];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapEditTagViewWithTapPoint:)]) {
        [self.delegate didTapEditTagViewWithTapPoint:point];
    }
}
- (void)didTapTagView:(UITapGestureRecognizer *)recognizer {
    TagView *tagView = (TagView *)recognizer.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEditTagView:)]) {
        [self.delegate didEditTagView:tagView];
    }
    if (self.gotoGoodsDetailBlock) {
        if (tagView.model.goodsId.length) {
            self.gotoGoodsDetailBlock(tagView.model.goodsId);
        }
    }
}
- (void)didLongPresssTagView:(UILongPressGestureRecognizer *)recognizer {
    cutView = (TagView *)recognizer.view;
    if (recognizer.state ==UIGestureRecognizerStateBegan) {
        [recognizer.view becomeFirstResponder];
        UIMenuController *popMenu = [UIMenuController sharedMenuController];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deletTagView)];
        NSArray *menuItems = [NSArray arrayWithObjects:item2,nil];
        [popMenu setMenuItems:menuItems];
        [popMenu setArrowDirection:UIMenuControllerArrowDown];
        [popMenu setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        [popMenu setMenuVisible:YES animated:YES];
    }
}
- (void)deletTagView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLongPressTagView:)]) {
        [self.delegate didLongPressTagView:cutView];
    }
}
#pragma mark - set get

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = self.bounds;
}
- (NSMutableArray *)tagViewArray {
    if (!_tagViewArray) {
        _tagViewArray = [NSMutableArray array];
    }
    return _tagViewArray;
}
- (NSMutableArray *)tagModelArray {
    if (!_tagModelArray) {
        _tagModelArray = [NSMutableArray array];
    }
    return _tagModelArray;
}
@end
