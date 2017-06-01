
#import "HomeGoodListCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
@interface HomeGoodListCollectionViewCell ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation HomeGoodListCollectionViewCell
- (void)showRightLine{
    self.lineView.hidden = NO;
}
- (void)hideRightLine{
    self.lineView.hidden = YES;

}
-(void)prepareForReuse{
    [super prepareForReuse];
    self.zanImageView.highlighted = self.model.isThumbsup.boolValue;
    [self.imageScrollView setContentOffset:CGPointZero];
}
-(void)setModel:(RJBaseGoodModel *)model{
    if (_model != model) {
        _model = model;
        //    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
        self.goodNameLabel.text = model.name;
        self.goodBrandLabel.text = model.brandName;
        self.markPriceLabel.attributedText = [NSString effectivePriceWithString:model.marketPrice];
        self.effectivePriceLabel.text = [NSString stringWithFormat:@"￥%@",model.effectivePrice];
        self.specialImageView.image = nil;
        
        self.effectivePriceLabel.textColor = [UIColor blackColor];
        
        if (model.isNewProduct.boolValue) {
            
            self.specialImageView.image = GetImage(@"xinping_right");
            
        }
        if (model.isSpecialPrice.boolValue) {
            self.effectivePriceLabel.textColor = [UIColor colorWithHexString:@"#F63649"];
            
            self.specialImageView.image = GetImage(@"tejia_right");
        }
        
        for (UIView *view in self.imageScrollView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        for (UIView *view  in self.pageControl.superview.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        [self.imageScrollView setContentOffset:CGPointZero];
        
        [self resetPlayer];
        
        CGFloat scrollWidth = SCREEN_WIDTH /2 - 20;
        for (int i= 0; i<model.imgsList.count; i++) {
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollWidth * i, 0, scrollWidth, scrollWidth)];
            
            RJGoodListImageListModel * imageModel = model.imgsList[i];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imgThumbnail] placeholderImage:GetImage(@"default_1x1")];
            [self.imageScrollView addSubview:imageView];
            
            if (imageModel.videoPath.length) {
                //播放按钮
                __weak __typeof(&*self)weakSelf = self;
                UIButton *btn = [[UIButton alloc]init];
                btn.tag = 1012;
                [btn setImage:[UIImage imageNamed:@"bofang_2"] forState:UIControlStateNormal];
                [self.pageControl.superview addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(weakSelf.pageControl.mas_centerY);
                    make.right.mas_equalTo(weakSelf.pageControl);
                    make.height.mas_equalTo(8);
                    make.width.mas_equalTo(8);
                }];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickVideo:)];
                imageView.tag = i + 30;
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:tap];
            }
        }
        [self.imageScrollView setContentSize:CGSizeMake(scrollWidth *model.imgsList.count, scrollWidth)];
        [self.viewOne bringSubviewToFront:self.specialImageView];
        self.pageControl.numberOfPages = model.imgsList.count;
        
        self.imageScrollView.goodsModel = model;
        NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
        if (self.fatherViewControllerName.length) {
            vcName = self.fatherViewControllerName;
        }
        self.likeButton.trackingId = [NSString stringWithFormat:@"%@&HomeGoodListCollectionViewCell&likeButton&id=%@",vcName,model.goodId];
    }
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.imageScrollView.delegate = self;
    self.imageScrollView.scrollsToTop = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [self.contentView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //如果是点击的imageView。忽略。
    if([touch.view isKindOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}
- (void)tapGestureAction:(UITapGestureRecognizer *)sender{
    UIView *view = sender.view;
    [self.delegate tapGsetureWithIndexRow:view.tag];

}
- (void)clickVideo:(UITapGestureRecognizer *)gesture {
    RJGoodListImageListModel * imageModel = self.model.imgsList[gesture.view.tag - 30];
    if (imageModel.videoPath.length) {
        if (_player) {
            return;
        }
        _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:imageModel.videoPath]];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = gesture.view.bounds;
        [gesture.view.layer addSublayer:_playerLayer];
        [_player play];
        
        //监听当视频播放结束时
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
        //    //监听播放失败时
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:[self.player currentItem]];
    }
}
- (void)playbackFinished:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero]; // item 跳转到初始
    if (item == _playerItem) {
        [self resetPlayer];
    }
}
- (void)resetPlayer {
    if (_playerLayer) {
        [_player pause];
        [_playerLayer removeFromSuperlayer];
        [_player replaceCurrentItemWithPlayerItem:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _playerLayer = nil;
        _playerItem = nil;
        _player = nil;
    }
}
- (void)playbackFailed:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero]; // item 跳转到初始
    if (item == _playerItem) {
        [self resetPlayer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollWidth = scrollView.frame.size.width;
    NSInteger i = (scrollView.contentOffset.x)/scrollWidth;
    self.pageControl.currentPage = i;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
