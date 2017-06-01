//
//  SMMatchView.m
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "SMMatchView.h"
#import "SMMatchEditView.h"
#import "SMMatchRecordToolBar.h"
#import "UIImageView+WebCache.h"
#import "SMMatchCutoutCollectionCell.h"
#import "SMMatchCutoutModel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Pixel.h"
#define KOperationCount 20
#define kCutCollectionHeith 60
#define KEditViewHeigth 50
#define KRecoderViewHeigth 50
#define KOperationCount 20
@interface SMMatchView()<SMMatchImageViewDelegate,SMMatchEditViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SMMatchRecordToolBarDelegate>
/** 编辑条：删除，克隆，翻转等 */
@property (nonatomic,strong)SMMatchEditView *editView;
/** 记录条：返回，前进，全屏 */
@property (nonatomic,strong)SMMatchRecordToolBar *recordToolBar;
/** 切图条 */
@property (nonatomic,strong)UICollectionView *collectionView;
/** 切图数据 */
@property (nonatomic,strong)NSMutableArray *dataArray;
/** 记录近20条操作 第一条操作为空*/
@property (nonatomic,strong)NSMutableArray *recordJsonDictArray;
/** 记录当前操作 */
@property (nonatomic,strong)NSArray *currentJsonArray;
@end
@implementation SMMatchView
{
    BOOL panState,rotateState,pinchState;
}
/** 添加图片容器， 添加手势 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        panState = YES;
        rotateState = YES;
        pinchState = YES;
        [self addGestureRecognizer];
        _matchImageArray = [NSMutableArray array];
        _recordJsonDictArray = [NSMutableArray array];
        _dataArray = [NSMutableArray array];
        //添加一个空数组。
        NSArray *startJsonArr = @[];
        [_recordJsonDictArray addObject:startJsonArr];
        self.currentJsonArray = startJsonArr;
        _imageContainerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
        _imageContainerView.userInteractionEnabled = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFit;
        _imageContainerView.image = GetImage(@"match_placeholderBg");
        [self addSubview:_imageContainerView];
        [self configCollectionView];
        [self addSubview:self.recordToolBar];
    }
    return self;
}
/** 初始化切图条 */
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(kCutCollectionHeith - 6, kCutCollectionHeith - 6);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.bounds.size.width - kCutCollectionHeith, kScreenWidth, kCutCollectionHeith) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.hidden = YES;
    [_collectionView registerClass:[SMMatchCutoutCollectionCell class] forCellWithReuseIdentifier:@"SMMatchCutoutCollectionCell"];
    [self addSubview:_collectionView];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:GetImage(@"match_hengtiao")];
}
/** 给面板添加手势 操控的是选中的图片*/
- (void)addGestureRecognizer {
    UITapGestureRecognizer *coverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
    [self addGestureRecognizer:coverTap];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(coverPinch:)];
    [self addGestureRecognizer:pinch];
    pinch.delegate = self;
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(coverRotate:)];
    [self addGestureRecognizer:rotateRecognizer];
    rotateRecognizer.delegate = self;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(coverPan:)];
    [self addGestureRecognizer:panGestureRecognizer];
    panGestureRecognizer.delegate = self;
    
}
#pragma mark -- 添加单品或素材
/** 添加单张图片，默认大小150*150，居中显示。
    并将其设置为已选状态。
    记录进操作
 */
/**
 设置图片为已选状态：
 self.selectImageView = nil;
 self.selectImageView = imgView;
 */
- (void)addImageWithImageModel:(SMGoodsModel *)goodsModel {
    
    /**
        先把背景中的单品删除
     */
    [self deleteBgGoodsImage];
    
    _imageContainerView.image = nil;
    SMMatchImageView *imgView = [[SMMatchImageView alloc]init];
    imgView.goodsModel = goodsModel;
    imgView.delegate = self;
    [_imageContainerView addSubview:imgView];
    
    [[HTUIHelper shareInstance] addHUDToView:self withString:nil xOffset:0 yOffset:0];
    [imgView sd_setImageWithURL:[NSURL URLWithString:goodsModel.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [[HTUIHelper shareInstance] removeHUD];
        if (error) {
            [imgView removeFromSuperview];
            [HTUIHelper addHUDToWindowWithString:@"图片加载失败" hideDelay:0.5];
            return;
        }
        CGFloat height,width;
        CGSize size = image.size;
        if (size.width > size.height) {
            width = 150;
            height = 150.0 / size.width * size.height;
        }else {
            height = 150;
            width = 150.0 / size.height * size.width;
        }
        imgView.frame = CGRectMake(0, 0, width, height);
        imgView.center = CGPointMake(kScreenWidth * 0.5, _imageContainerView.height * 0.5);
        [self.matchImageArray addObject:imgView];
        self.selectImageView = nil;
        self.selectImageView = imgView;
        [self addRecordJsonArray];
    }];
}
#pragma mark -- 克隆图片
- (void)addImageWithImageView:(SMMatchImageView *)imageView {
    SMMatchImageView *imgView = [[SMMatchImageView alloc]init];
    imgView.goodsModel = imageView.goodsModel;
    imgView.delegate = self;
    [_imageContainerView addSubview:imgView];
    imgView.center = CGPointMake(imageView.center.x + 20, imageView.center.y + 20);
    
    CGPoint center = imgView.center;
    if (imgView.center.x <= 20 || imgView.center.x >= _imageContainerView.width - 20) {
        center.x = _imageContainerView.width * 0.5;
    }
    if (imgView.center.y <= 20 || imgView.center.y >= _imageContainerView.height - 20) {
        center.y = _imageContainerView.height * 0.5;
    }
    imgView.center = center;
    imgView.bounds = imageView.bounds;
    [imgView sd_setImageWithURL:[NSURL URLWithString:imageView.goodsModel.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    imgView.isFlipX = imageView.isFlipX;
    imgView.isBgImage = imageView.isBgImage;
    imgView.transform = imageView.transform;
    
    [self.matchImageArray addObject:imgView];
    self.selectImageView = nil;
    self.selectImageView = imgView;
    [self addRecordJsonArray];
}

#pragma mark -- 通过草稿添加图片背景到面板上 （只用draft字段
- (void)addImagesWithDraftModel:(SMMatchDraftModel *)draftModel {
    
    //删除面板引导图
    _imageContainerView.image = nil;
    
    //删除所有操作
    [self deleteAllRecord];
    
    NSString *draftString = draftModel.draft;
    NSData *data = [draftString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        for (NSDictionary *containtDict in dic[@"data"]) {
            SMMatchImageView *imgView = [[SMMatchImageView alloc]init];
            SMGoodsModel *model = [[SMGoodsModel alloc] init];
            if (containtDict[@"id"]) {
                model.ID = containtDict[@"id"];
            }
            model.image = containtDict[@"image"];
            imgView.goodsModel = model;
            imgView.delegate = self;
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [_imageContainerView addSubview:imgView];
            CGFloat scale = kScreenWidth / [containtDict[@"screenWidth"] floatValue];
            CGPoint center = CGPointFromString(containtDict[@"center"]);
            CGRect bounds = CGRectFromString(containtDict[@"bounds"]);
            imgView.center = CGPointMake(center.x * scale, center.y * scale);
            imgView.bounds = CGRectMake(0, 0, bounds.size.width * scale, bounds.size.height * scale);
            imgView.isFlipX = [containtDict[@"isFlipX"] boolValue];
            [imgView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"] completed:nil];
            imgView.transform = CGAffineTransformFromString(containtDict[@"transform"]);
            imgView.isBgImage = [containtDict[@"isBgImage"] boolValue];
            [self.matchImageArray addObject:imgView];
        }
    }
}
//同样可以用这个方法还原草稿
//- (void)addImagesWithDraftModel:(SMMatchDraftModel *)draftModel {
//    //删除面板引导图
//    _imageContainerView.image = nil;
//    
//    //删除所有操作
//    [self deleteAllRecord];
//    
//    NSString *draftString = draftModel.draft;
//    NSData *data = [draftString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//    if (!error) {
//        for (NSDictionary *containtDict in dic[@"data"]) {
//            SMMatchImageView *imgView = [[SMMatchImageView alloc]init];
//            SMGoodsModel *model = [[SMGoodsModel alloc] init];
//            if (containtDict[@"id"]) {
//                model.ID = containtDict[@"id"];
//            }
//            model.image = containtDict[@"image"];
//            imgView.goodsModel = model;
//            imgView.delegate = self;
//            imgView.contentMode = UIViewContentModeScaleAspectFit;
//            [_imageContainerView addSubview:imgView];
//            imgView.isFlipX = [containtDict[@"isFlipX"] boolValue];
//            [imgView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"placeHodler"] completed:nil];
//            
//            
//            imgView.center = CGPointFromString(containtDict[@"center"]);
//            CGRect bounds = CGRectFromString(containtDict[@"bounds"]);
//            imgView.bounds = bounds;
//            
//            //还原角度和缩放倍数
//            CGFloat angle = [containtDict[@"angle"] floatValue];
//            CGFloat scale = [containtDict[@"scale"] floatValue];
//            if (imgView.isFlipX) {
//                scale = - scale;
//            }
//            angle = [self getAngleWithAngle:angle isFlipX:imgView.isFlipX];
//            
//            //构建transform
//            CGFloat f = imgView.isFlipX ? (-1) : 1;
//            CGFloat a = f * scale * cos(angle);
//            CGFloat b = f * scale * sin(angle);
//            CGFloat c = - scale * sin(angle);
//            CGFloat d = scale * cos(angle);
//            imgView.transform = CGAffineTransformMake(a, b, c, d, 0, 0);
//            
//            [self.matchImageArray addObject:imgView];
//        }
//    }
//}

- (CGFloat)getAngleWithAngle:(CGFloat)angle isFlipX:(BOOL)isFlipX{
    CGFloat originalAngle = angle;
    if (isFlipX) {
        angle = angle / 180.0 * M_PI + M_PI;
    }else {
        angle = angle / 180.0 * M_PI;
    }

    if (originalAngle >= 0 && originalAngle < 90) {
        angle = angle;
    }else if (originalAngle >= 90 && originalAngle < 180) {
        angle = angle - M_PI;
    }else if (originalAngle >= 180 && originalAngle < 270) {
        angle = angle - M_PI;
    }else {
        angle = angle - 2 * M_PI;
    }
    return angle;
}
- (void)deleteBgGoodsImage {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SMMatchImageView class]]) {
            [view removeFromSuperview];
        }
    }
    //下面可以注释了
    for (SMMatchImageView *matchImage in self.imageContainerView.subviews) {
        if (matchImage.isBgGoodImage) {
            [matchImage removeFromSuperview];
        }
    }
}
- (void)deleteBgImage {
    [self deleteBgGoodsImage];
    //先把，已经添加的背景从面板删除掉。
    NSMutableArray *tempBgMatchImageArray = [NSMutableArray array];
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        if (matchImage.isBgImage) {
            [matchImage removeFromSuperview];
        }else {
            [tempBgMatchImageArray addObject:matchImage];
        }
    }
    //将临时数组赋值给matchImageArray ，删除掉了背景图
    [_matchImageArray removeAllObjects];
    [_matchImageArray addObjectsFromArray:tempBgMatchImageArray];
    
}
#pragma mark -- 将自定义背景添加到面板中
- (void)addBgImagesWithSelfDefineBgDraftModelArray:(NSArray *)draftModelArray {
    if (draftModelArray.count == 0) {
        return;
    }
    _imageContainerView.image = nil;
    
    /**
        1.先把存在的背景删除
     */
    [self deleteBgImage];
    
    /**
        2.将背景添加到面板上(底层)
     */
    
    //存放已经计算好frame的背景图片
    //URL 中含有# 的是单品
    NSArray *matchImageArray = [self updateBgFrameWithArr:draftModelArray];
    BOOL containGoods = NO;
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        if (matchImage.goodsModel.ID.length) {
            containGoods = YES;
        }
    }
    for (SMMatchImageView *matchImage in matchImageArray) {
        
        if (containGoods && [matchImage.goodsModel.image containsString:@"#"]) {
            continue;
        }
        
        if ([matchImage.goodsModel.image containsString:@"#"]) {
            matchImage.userInteractionEnabled = NO;
            matchImage.isBgGoodImage = YES;
        }
        //文字不显示。不支持文字显示功能
        if (!matchImage.goodsModel.image) {
            continue;
        }
        matchImage.delegate = self;
//        int i = 0;
//        [self.imageContainerView insertSubview:matchImage atIndex:i];
//        i++;
        int j = 0;
        if (![matchImage.goodsModel.image containsString:@"#"]) {
            [self.matchImageArray insertObject:matchImage atIndex:j];
            [self.imageContainerView insertSubview:matchImage atIndex:j];
            j++;
        }else {
            //背景不添加到面板中，以避免：图层关系难题，等
            [self addSubview:matchImage];
        }
    }
    [self addRecordJsonArray];
}
- (void)deleteAllRecord {
    [_recordJsonDictArray removeAllObjects];
    //添加一个空数组。
    NSArray *startJsonArr = @[];
    [_recordJsonDictArray addObject:startJsonArr];
    self.currentJsonArray = startJsonArr;
    [self.recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeBack enabled:NO];
    [self.recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeForword enabled:NO];
    [self.recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:NO];
}
- (NSArray *)updateBgFrameWithArr:(NSArray *)array {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10000, 10000)];
    NSMutableArray *imageArray = [NSMutableArray array];
    for (SMBackgroundDraftModel *model in array) {
        SMMatchImageView *imageView = [[SMMatchImageView alloc] init];
        SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
        imageView.isBgImage = YES;
        if ([model.type isEqualToString:@"text"]) {
        }else {
            goodsModel.image = model.src;
        }
        imageView.goodsModel = goodsModel;
        imageView.isFlipX = model.flipX;
        imageView.frame = CGRectMake(model.left, model.top, model.width * model.scaleX, model.height * model.scaleY);
        imageView.transform = CGAffineTransformRotate(imageView.transform, model.angle / 180.0 * M_PI);
        if (model.flipX) {
            imageView.transform = CGAffineTransformScale(imageView.transform, -1, 1);
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.src] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([imageURL.absoluteString containsString:@"#"]) {
                imageView.image = [UIImage imageBlackToTransparent:image withRed:239 andGreen:239 andBlue:239 alpha:100];
            }
        }];
        [view addSubview:imageView];
        [imageArray addObject:imageView];
    }
    //1.找到矩形框
    CGFloat maxX = 0;
    CGFloat minX = 1000000;
    CGFloat maxY = 0;
    CGFloat minY = 1000000;
    for (SMMatchImageView *matchImage in imageArray) {
        CGRect rect = matchImage.frame;
        if (maxX <= CGRectGetMaxX(rect)) {
            maxX = CGRectGetMaxX(rect);
        }
        if (maxY <= CGRectGetMaxY(rect)) {
            maxY = CGRectGetMaxY(rect);
        }
        if (minX >= CGRectGetMinX(rect)) {
            minX = CGRectGetMinX(rect);
        }
        if (minY >= CGRectGetMinY(rect)) {
            minY = CGRectGetMinY(rect);
        }
    }
    
    CGFloat scale = 1;
    CGRect currentAreaRect = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    //确定缩放倍数
    if (currentAreaRect.size.width > currentAreaRect.size.height) {
        scale = _imageContainerView.bounds.size.width / currentAreaRect.size.width;
    }else {
        scale = _imageContainerView.bounds.size.height / currentAreaRect.size.height;
    }
    for (SMMatchImageView *matchImage in imageArray) {
        
        //1, 先移动中心点
        CGRect frame = matchImage.frame;
        CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
        CGFloat moveX = center.x * (scale - 1);
        CGFloat moveY = center.y * (scale - 1);
        //1, 在改变大小
        matchImage.center = CGPointMake(matchImage.center.x + moveX, matchImage.center.y + moveY);
        CGRect rect = matchImage.bounds;
        rect.size.width = rect.size.width * scale;
        rect.size.height = rect.size.height * scale;
        matchImage.bounds = rect;
    }
    
    maxX = 0;
    minX = 1000000;
    maxY = 0;
    minY = 1000000;
    for (SMMatchImageView *matchImage in imageArray) {
        CGRect rect = matchImage.frame;
        if (maxX <= CGRectGetMaxX(rect)) {
            maxX = CGRectGetMaxX(rect);
        }
        if (maxY <= CGRectGetMaxY(rect)) {
            maxY = CGRectGetMaxY(rect);
        }
        if (minX >= CGRectGetMinX(rect)) {
            minX = CGRectGetMinX(rect);
        }
        if (minY >= CGRectGetMinY(rect)) {
            minY = CGRectGetMinY(rect);
        }
    }
    CGFloat moveX = _imageContainerView.bounds.size.width * 0.5 - (minX + (maxX - minX)*0.5) ;
    CGFloat moveY = _imageContainerView.bounds.size.height * 0.5 - (minY + (maxY - minY)*0.5);
    for (SMMatchImageView *matchImage in imageArray) {
        matchImage.center = CGPointMake(matchImage.center.x + moveX, matchImage.center.y + moveY);
    }
    NSArray* reversedArray = [[imageArray reverseObjectEnumerator] allObjects];
    return reversedArray;
}
#pragma mark - 手势
/** 背景旋转 */
- (void)coverRotate:(UIRotationGestureRecognizer *)recognizer {
    if (!self.selectImageView) {
        return;
    }
    self.selectImageView.transform = CGAffineTransformRotate(self.selectImageView.transform, (self.selectImageView.isFlipX ? (-1):1) * recognizer.rotation);
    recognizer.rotation = 0;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rotateState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        rotateState = YES;
    }
    if (rotateState && pinchState && panState) {
        [self addRecordJsonArray];
//        NSLog(@"transform  -- %@",NSStringFromCGAffineTransform(self.selectImageView.transform));
//        NSLog(@"bounds -- %@",NSStringFromCGRect(self.selectImageView.bounds));
//        NSLog(@"center -- %@",NSStringFromCGPoint(self.selectImageView.center));
//        NSLog(@"\n angle \n %.2f \n",[self getAngleFromTransform:self.selectImageView.transform]);
//        NSLog(@"\n scale \n %.2f \n",[self getScaleFromTransform:self.selectImageView.transform]);
    }
}
/**点击背景*/
- (void)coverViewTap:(UITapGestureRecognizer *)tap {
    self.selectImageView = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapMatchView:)]) {
        [self.delegate didTapMatchView:self];
    }
}
/** 背景缩放 */
- (void)coverPinch:(UIPinchGestureRecognizer *)recognizer {
    if (!self.selectImageView) {
        return;
    }
    
    /**
     
        限制缩放在固定尺寸
     
     */
    CGAffineTransform transform = CGAffineTransformScale(self.selectImageView.transform, recognizer.scale, recognizer.scale);
    if (self.selectImageView.bounds.size.width * [self getScaleFromTransform:transform] <= 40 || self.selectImageView.bounds.size.height * [self getScaleFromTransform:transform] <= 40) {
        return;
    }
    
    self.selectImageView.transform = CGAffineTransformScale(self.selectImageView.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        pinchState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        pinchState = YES;
    }
    if (rotateState && pinchState && panState) {
        [self addRecordJsonArray];
//        NSLog(@"transform  -- %@",NSStringFromCGAffineTransform(self.selectImageView.transform));
//        NSLog(@"bounds -- %@",NSStringFromCGRect(self.selectImageView.bounds));
//        NSLog(@"center -- %@",NSStringFromCGPoint(self.selectImageView.center));
//        NSLog(@"\n angle \n %.2f \n",[self getAngleFromTransform:self.selectImageView.transform]);
//        NSLog(@"\n scale \n %.2f \n",[self getScaleFromTransform:self.selectImageView.transform]);
    }
}
/** 背景拖动 */
- (void)coverPan:(UIPanGestureRecognizer *)recognizer{
    if (!self.selectImageView) {
        return;
    }
    CGPoint originalCenter = self.selectImageView.center;
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    self.selectImageView.center = CGPointMake(self.selectImageView.center.x + translation.x, self.selectImageView.center.y + translation.y);
    
    /**
    限制边距
    */
    
//    CGPoint center = self.selectImageView.center;
//    CGRect frame = self.selectImageView.frame;
//    
//    if (CGRectGetMaxX(frame) >= kScreenWidth) {
//        if (center.x > originalCenter.x) {
//            center.x = originalCenter.x;
//        }
//    }
//    if (CGRectGetMinX(frame) <= 0) {
//        if (center.x < originalCenter.x) {
//            center.x = originalCenter.x;
//        }
//    }
//    if (CGRectGetMaxY(frame) >= kScreenWidth) {
//        if (center.y > originalCenter.y) {
//            center.y = originalCenter.y;
//        }
//    }
//    if (CGRectGetMinY(frame) <= 0) {
//        if (center.y < originalCenter.y) {
//            center.y = originalCenter.y;
//        }
//    }
//    
//    self.selectImageView.center = center;
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        panState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        panState = YES;
    }
    if (rotateState && pinchState && panState) {
        [self addRecordJsonArray];
    }
}
#pragma mark - image delegate
/** 点击面板上的图片 */
- (void)didTapMatchImage:(SMMatchImageView *)imageView {
    self.selectImageView = nil;
    self.selectImageView = imageView;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapMatchImage:)]) {
        [self.delegate didTapMatchImage:self];
    }
}
//图片的各种手势事件
- (void)didReseiveImageRegesture:(UIGestureRecognizer *)recognizer {
    [self addRecordJsonArray];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - editBar delegate
/** 点击编辑条上的功能按钮 */
- (void)didClickEditView:(SMMatchEditView *)editView buttonType:(SMMatchEditButtonType)buttonType {
    [self.recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:YES];
    switch (buttonType) {
        case SMMatchEditButtonTypeRemove:
            [self removeMatchImage:self.selectImageView];
            break;
        case SMMatchEditButtonTypeFlip:
            [self filpMatchImage:self.selectImageView];
            break;
        case SMMatchEditButtonTypeClone:
            [self cloneMatchImage:self.selectImageView];
            break;
        case SMMatchEditButtonTypeCutout:
            [self cutoutMatchImage:self.selectImageView];
            break;
        case SMMatchEditButtonTypeForward:
            [self forwordMatchImage:self.selectImageView];
            break;
        case SMMatchEditButtonTypeBack:
            [self backMatchImage:self.selectImageView];
            break;
            
        default:
            break;
    }
}
#pragma mark - recordBar delegate
/** 点击了记录条上的按钮：返回，前进，全屏 */
- (void)didClickRecordToolBar:(SMMatchRecordToolBar *)toolBar buttonType:(SMMatchRecordToolBarType)tooBarType {
    [self recordMatchImageWith:tooBarType recordToolBar:toolBar];
}
#pragma mark - recordToolBar 记录与回放操作
#pragma mark -- 添加记录
/**只添加一个单品数据展示(recordJsonDictArray)：
 <__NSArrayM 0x17424b9a0>(
 <__NSArray0 0x174005130>(
 
 )
 ,
 <__NSArrayM 0x1744407e0>(
 {
 angle = 0;
 bounds = "{{0, 0}, {150, 150}}";
 center = "{187.5, 187.5}";
 count = 1;
 id = 2062;
 image = "http://www.ssrj.com/upload/image/201610/d9b94392-7901-4369-a55d-44b226f9611f-medium.png";
 isFlipX = 0;
 jsonId = 0;
 scale = 1;
 screenWidth = 375;
 transform = "[1, 0, 0, 1, 0, 0]";
 }
 )
 
 )
 */
//每次操作都要记录
// bounds.size.width * scale 是显示出来的宽度
// bounds.size.height * scale 是显示出来的高度
- (void)addRecordJsonArray {
    static int tag = 0;
    NSMutableArray *jsonArray = [NSMutableArray array];
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:NSStringFromCGPoint(matchImage.center) forKey:@"center"];
        [dict setObject:NSStringFromCGRect(matchImage.bounds) forKey:@"bounds"];
        [dict setObject:@(1) forKey:@"count"];
        [dict setObject:NSStringFromCGAffineTransform(matchImage.transform) forKey:@"transform"];
        [dict setObject:@(kScreenWidth) forKey:@"screenWidth"];
        [dict setObject:@(matchImage.isFlipX) forKey:@"isFlipX"];
        [dict setObject:@([self getAngleFromTransform:matchImage.transform]) forKey:@"angle"];
        [dict setObject:@([self getScaleFromTransform:matchImage.transform]) forKey:@"scale"];
        if (matchImage.goodsModel.ID.length) {[dict setObject:matchImage.goodsModel.ID  forKey:@"id"];
        }
        [dict setObject:matchImage.goodsModel.image forKey:@"image"];
        [dict setObject:@(matchImage.isBgImage) forKey:@"isBgImage"];
        [dict setObject:@(tag) forKey:@"jsonId"];
        [jsonArray addObject:[dict mutableCopy]];
        tag++;
    }
    
    //修改记录条的点击状态
    if (jsonArray.count == 0) {
        [_recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:NO];
    }else {
        [_recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:YES];
    }
    
    [_recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeBack enabled:YES];
    [_recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeForword enabled:NO];
    
    //记录中如果没有任何图片，也是有添加id，来标记这个记录的唯一性
    if (jsonArray.count == 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"0" forKey:@"count"];
        [dict setObject:@(tag) forKey:@"jsonId"];
        [jsonArray addObject:dict];
        tag++;
    }
    //操作发生，将操作后的记录全部删除
    if ([self.recordJsonDictArray containsObject:self.currentJsonArray]) {
        NSUInteger index = [self.recordJsonDictArray indexOfObject:self.currentJsonArray];
        [self.recordJsonDictArray removeObjectsInRange:NSMakeRange(index + 1, self.recordJsonDictArray.count - index - 1)];
    }else {
    }
    //限制记录操作条数
    if (self.recordJsonDictArray.count == KOperationCount) {
        [self.recordJsonDictArray removeObjectAtIndex:0];
    }
    NSMutableArray *temArray = [jsonArray mutableCopy];
    [self.recordJsonDictArray addObject:temArray];
    self.currentJsonArray = [self.recordJsonDictArray lastObject];

}
#pragma mark -- 点击前进后退
/** 点击记录条的功能，执行相应的后退，前进，全屏 */
- (void)recordMatchImageWith:(SMMatchRecordToolBarType)type recordToolBar:(SMMatchRecordToolBar *)toolBar{
    if ([self.recordJsonDictArray containsObject:self.currentJsonArray]) {
        NSUInteger index = [self.recordJsonDictArray indexOfObject:self.currentJsonArray];
        //后退
        if (type == SMMatchRecordToolBarTypeBack) {
            //后台，指针指向上一个。当指向第一个的时候把button设置为不可点击状态.前进设为可点击。
            self.currentJsonArray = [self.recordJsonDictArray objectAtIndex:index -1];
            [self updateMatchViewWithJsonArray:self.currentJsonArray];
            if (index - 1 == 0) {
                [toolBar setRecordBarWithButtonType:type enabled:NO];
            }
            
            [toolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeForword enabled:YES];
        }
        //前进
        else if (type == SMMatchRecordToolBarTypeForword) {
            //前进，指针指向后一个。当指向最后一个的时候把button设置为不可点击状态,后台设为可点击
            self.currentJsonArray = [self.recordJsonDictArray objectAtIndex:index + 1];
            [self updateMatchViewWithJsonArray:self.currentJsonArray];
            if (index + 1 == self.recordJsonDictArray.count - 1) {
                [toolBar setRecordBarWithButtonType:type enabled:NO];
            }
            [toolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeBack enabled:YES];
        }
        //全屏
        else if (type == SMMatchRecordToolBarTypeAllScreen){
            [self updateFrameWhenAllScreen];
            [self addRecordJsonArray];
            [toolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:NO];
        }
    }
}
/** 根据记录的信息重画面板中的图片 */
- (void)updateMatchViewWithJsonArray:(NSArray *)jsonArray {
    //首先把图片从容器和数组中删掉
    for (UIView *matchImage in _imageContainerView.subviews) {
        if ([matchImage isKindOfClass:[SMMatchImageView class]]) {
            [matchImage removeFromSuperview];
        }
    }
    [self.matchImageArray removeAllObjects];
    BOOL hasMatchImage = NO;
    for (NSDictionary *dic in jsonArray) {
        if ([dic[@"count"]intValue] == 0) {
        }else {
            hasMatchImage = YES;
            [self addImageWithDict:dic];
        }
    }
    
    //有内容，就可以全屏
    [_recordToolBar setRecordBarWithButtonType:SMMatchRecordToolBarTypeAllScreen enabled:hasMatchImage];
}
/** 根据记录的信息创建对应的图片 */
- (void)addImageWithDict:(NSDictionary *)dict {
    SMMatchImageView *imgView = [[SMMatchImageView alloc]init];
    SMGoodsModel *model = [[SMGoodsModel alloc] init];
    
    if (dict[@"id"]) {
        model.ID = dict[@"id"];
    }
    model.image = dict[@"image"];
    imgView.goodsModel = model;
    imgView.delegate = self;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.center = CGPointFromString(dict[@"center"]);
    imgView.bounds = CGRectFromString(dict[@"bounds"]);
    imgView.isBgImage = [dict[@"isBgImage"] boolValue];
    [imgView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    imgView.transform = CGAffineTransformFromString(dict[@"transform"]);
    imgView.isFlipX = [dict[@"isFlipX"] boolValue];
    [_imageContainerView addSubview:imgView];
    [self.matchImageArray addObject:imgView];
}
- (void)updateFrameWhenAllScreen {
    CGFloat maxX = 0;
    CGFloat minX = 10000000;
    CGFloat maxY = 0;
    CGFloat minY = 10000000;
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        CGRect rect = matchImage.frame;
//        NSLog(@"aaaaaa fame --  %@ \n aaaaa bounds--  %@",NSStringFromCGRect(matchImage.frame),NSStringFromCGRect(matchImage.bounds));
        if (maxX <= CGRectGetMaxX(rect)) {
            maxX = CGRectGetMaxX(rect);
        }
        if (maxY <= CGRectGetMaxY(rect)) {
            maxY = CGRectGetMaxY(rect);
        }
        if (minX >= CGRectGetMinX(rect)) {
            minX = CGRectGetMinX(rect);
        }
        if (minY >= CGRectGetMinY(rect)) {
            minY = CGRectGetMinY(rect);
        }
    }
    
    CGFloat scale = 1;
    CGRect currentAreaRect = CGRectMake(minX, minY, maxX-minX, maxY-minY);
//    NSLog(@"currentAreaRect -- %@", NSStringFromCGRect(currentAreaRect));
    if (currentAreaRect.size.width > currentAreaRect.size.height) {
        scale = _imageContainerView.bounds.size.width / currentAreaRect.size.width;
    }else {
        scale = _imageContainerView.bounds.size.width / currentAreaRect.size.height;
    }
//    NSLog(@"%.2f",scale);
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        CGRect rect = matchImage.bounds;
        matchImage.center = CGPointMake((matchImage.center.x - minX) * scale, (matchImage.center.y - minY) * scale);
        rect.size.width = rect.size.width * scale;
        rect.size.height = rect.size.height * scale;
        matchImage.bounds = rect;
//        NSLog(@"scaleafter fame --  %@ \n scaleafter bounds--  %@",NSStringFromCGRect(matchImage.frame),NSStringFromCGRect(matchImage.bounds));
    }
    
    maxX = 0;
    minX = 10000000;
    maxY = 0;
    minY = 10000000;
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        CGRect rect = matchImage.frame;
        if (maxX <= CGRectGetMaxX(rect)) {
            maxX = CGRectGetMaxX(rect);
        }
        if (maxY <= CGRectGetMaxY(rect)) {
            maxY = CGRectGetMaxY(rect);
        }
        if (minX >= CGRectGetMinX(rect)) {
            minX = CGRectGetMinX(rect);
        }
        if (minY >= CGRectGetMinY(rect)) {
            minY = CGRectGetMinY(rect);
        }
    }
    CGFloat moveX = _imageContainerView.bounds.size.width * 0.5 - (minX + maxX) * 0.5;
    CGFloat moveY = _imageContainerView.bounds.size.height * 0.5 - (minY + maxY) * 0.5;
//    NSLog(@"moveX %.2f  ++++  moveY %.2f", moveX,moveY);
    for (SMMatchImageView *matchImage in self.matchImageArray) {
        if (self.selectImageView == matchImage) {
        }
        matchImage.center = CGPointMake(matchImage.center.x + moveX, matchImage.center.y + moveY);
//        NSLog(@"allScreen frame --  %@ \n allscreen bounds--  %@",NSStringFromCGRect(matchImage.frame),NSStringFromCGRect(matchImage.bounds));
    }
}
//根据transform 获得旋转角度
- (CGFloat)getAngleFromTransform:(CGAffineTransform)transform {
    
    CGFloat angle = atanf(transform.b / transform.a);
    //第一象限，角度不变
    if (transform.a > 0 && transform.b >= 0) {
    }
    //第二象限，角度加M_PI
    else if (transform.a <= 0 && transform.b > 0) {
        angle = M_PI + angle;
    }
    //第三象限，角度加M_PI
    else if (transform.a < 0 && transform.b <= 0) {
        angle = M_PI + angle;
    }
    //第四象限，角度加2 * M_PI
    else {
        angle = 2 * M_PI + angle;
        if (angle == 2 * M_PI) {
            angle = 0;
        }
    }
    if (self.selectImageView.isFlipX) {
        angle = angle - M_PI;
    }
    return angle * 180 / M_PI;
}
//根据transform 获得放大倍数
- (CGFloat)getScaleFromTransform:(CGAffineTransform)transform {
    CGFloat angle = atanf(transform.b / transform.a);
    CGFloat scale = transform.a / cos(angle);
//    NSLog(@"不考虑flip--  scale --- %f",scale);
    //翻转scale会变为负数。取绝对值
    return fabs(scale);
}
#pragma mark - 点击编辑条：删除，翻转...
/** 删除 */
- (void)removeMatchImage:(SMMatchImageView *)matchImage {
    [matchImage removeFromSuperview];
    [self.matchImageArray removeObject:matchImage];
    self.selectImageView = nil;
    [self addRecordJsonArray];
}
/** 翻转 */
- (void)filpMatchImage:(SMMatchImageView *)matchImage {
    [UIView animateWithDuration:0.3 animations:^{
        
        matchImage.transform = CGAffineTransformScale(matchImage.transform, -1, 1);
    }];
    matchImage.isFlipX = !matchImage.isFlipX;
    [self addRecordJsonArray];

}
/** 复制 */
- (void)cloneMatchImage:(SMMatchImageView *)matchImage {
    [self addImageWithImageView:matchImage];
}
/** 裁剪 */
- (void)cutoutMatchImage:(SMMatchImageView *)matchImage {
    _collectionView.hidden = !_collectionView.hidden;
    if (_collectionView.hidden == NO) {
        [self getCutoutDataWithGoodsModel:matchImage.goodsModel];
    }
}
/** 上移 */
- (void)forwordMatchImage:(SMMatchImageView *)matchImage {
    if([_imageContainerView subviews].count == 0) return;
    NSInteger index_selectImage = [[_imageContainerView subviews] indexOfObject:matchImage];
    if (index_selectImage < _imageContainerView.subviews.count-1) {
        [_imageContainerView exchangeSubviewAtIndex:index_selectImage withSubviewAtIndex:index_selectImage + 1];
        [_matchImageArray exchangeObjectAtIndex:index_selectImage withObjectAtIndex:index_selectImage + 1];
        [self addRecordJsonArray];
    }else {
    }
    [self.editView setEditviewStateWithMatchImage:matchImage];
}
/** 下移 */
- (void)backMatchImage:(SMMatchImageView *)matchImage {
    if([_imageContainerView subviews].count == 0) return;
    if ([[_imageContainerView subviews] containsObject:matchImage]) {
        NSInteger index_selectImage = [[_imageContainerView subviews] indexOfObject:matchImage];
        if (index_selectImage > 0) {
            [_imageContainerView exchangeSubviewAtIndex:index_selectImage withSubviewAtIndex:index_selectImage - 1];
            [_matchImageArray exchangeObjectAtIndex:index_selectImage withObjectAtIndex:index_selectImage - 1];
            [self addRecordJsonArray];
        }else {
            [HTUIHelper addHUDToWindowWithString:@"不能下移了" hideDelay:1];
        }
    }
    [self.editView setEditviewStateWithMatchImage:matchImage];
    
}
#pragma mark - get
- (SMMatchEditView *)editView {
    if (!_editView) {
        _editView = [[SMMatchEditView alloc] initWithFrame:CGRectMake(0, kScreenWidth, kScreenWidth, KEditViewHeigth)];
        _editView.delegate = self;
        _editView.backgroundColor = [UIColor whiteColor];
    }
    return _editView;
}
- (SMMatchRecordToolBar *)recordToolBar {
    if (!_recordToolBar) {
        _recordToolBar = [[SMMatchRecordToolBar alloc] initWithFrame:CGRectMake(0, kScreenWidth, kScreenWidth, 50)];
        _recordToolBar.delegate = self;
        _recordToolBar.backgroundColor = [UIColor whiteColor];
    }
    return _recordToolBar;
}
/** 控制编辑条和记录条的显示和隐藏
    控制选中和非选中图片
 */
- (void)setSelectImageView:(SMMatchImageView *)selectImageView {
    //选中，将选中图片加边框，其他控件要虚化，并且其他控件不能响应事件
    if (selectImageView) {
        [self addSubview:self.editView];
        [self bringSubviewToFront:self.editView];
        [self.recordToolBar removeFromSuperview];
        [self.editView setEditviewStateWithMatchImage:selectImageView];
        selectImageView.userInteractionEnabled = NO;
        selectImageView.alpha = 1;
        selectImageView.borderLayer.hidden = NO;
        for (SMMatchImageView *view in _imageContainerView.subviews) {
            if (view == selectImageView) {
                
            }else {
                view.alpha = 0.2;
            }
            view.userInteractionEnabled = NO;
        }
    }
    //取消选中，选中图片去边框，其他控件实体化，并且其他控件能响应事件
    else {
        self.collectionView.hidden = YES;
        [self.editView removeFromSuperview];
        [self.recordToolBar removeFromSuperview];
        [self addSubview:self.recordToolBar];
        if(_selectImageView) {
            _selectImageView.userInteractionEnabled = YES;
            _selectImageView.borderLayer.hidden = YES;
            for (SMMatchImageView *view in _imageContainerView.subviews) {
                if (view == _selectImageView) {
                    
                }else {
                    view.alpha = 1;
                }
                //背景图中的单品是不让选中的
                if (!view.isBgGoodImage) {
                    view.userInteractionEnabled = YES;
                }
            }
        }
        
    }
    
    _selectImageView = selectImageView;
}
#pragma mark - network
/**http://192.168.1.173:9999/api/v1/collocation/cutout?goods=1989&pagenum=1&pagesize=100000&appVersion=2.2.0&token=da83e19a50a084522343d96746f0d889
 
 "data": [{"thumbnail": "", "image": "http://www.ssrj.cn/static/upload/image/201609/e43730bf-6247-48c7-ad31-2b565dd554ae-source.png", "goods": "1989", "id": 17261, "title": "\u9ed1\u8272\u76ae\u9769\u9ad8\u8ddf\u957f\u9774"}, ......
 */
/** 获取切图数据 */
- (void)getCutoutDataWithGoodsModel:(SMGoodsModel *)model {
    [self.dataArray removeAllObjects];
    [self.collectionView reloadData];
    //id 为空。是自己从相册选择的图片或者素材。没有切图
    if (!model.ID.length) {
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/collocation/cutout?goods=%@&pagenum=1&pagesize=100000",model.ID];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject[@"state"] intValue] == 0) {
                NSArray *dictArr = responseObject[@"data"];
                for (NSDictionary *dict in dictArr) {
                    NSError *error = nil;
                    SMMatchCutoutModel *model = [[SMMatchCutoutModel alloc] initWithDictionary:dict error:&error];
                    [weakSelf.dataArray addObject:model];
                }
            }else{
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        [weakSelf.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
    }];
}

#pragma mark - collectionDeledate 切图代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMatchCutoutModel *model = self.dataArray[indexPath.row];
    SMMatchCutoutCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SMMatchCutoutCollectionCell" forIndexPath:indexPath];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.ID.intValue];
    
    cell.cutModel = model;
    __weak __typeof(&*self)weakSelf = self;
    
    //点击切图，换图片
    cell.clickBlock = ^ {
        for (SMMatchCutoutModel *cutModel in weakSelf.dataArray) {
            cutModel.selected = @0;
        }
        SMMatchCutoutModel *model = weakSelf.dataArray[indexPath.row];
        model.selected = @1;
        [weakSelf.collectionView reloadData];
        SMGoodsModel *goodsModel = weakSelf.selectImageView.goodsModel;
        goodsModel.image = model.image;
        weakSelf.selectImageView.goodsModel = goodsModel;
        [weakSelf.selectImageView sd_setImageWithURL:[NSURL URLWithString:goodsModel.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            /**
             剪切大小规则，将剪切图原图先按长边150算，如果selectImage 的bounds放大了。长边按150 * 缩放倍数 计算。 实际显示出来的大小并不一定是bounds大小，因为selectImage 只是图片，bounds变了，transform并没有变。所以实际显示大小是：bounds * transform
             */
            CGFloat height,width;
            CGSize size = image.size;
            
            //bounds放大了几倍。
            CGRect imageBounds = weakSelf.selectImageView.bounds;
            CGFloat scale;
            if (imageBounds.size.width > imageBounds.size.height) {
                scale = imageBounds.size.width / 150.0;
            }else {
                scale = imageBounds.size.height / 150.0;
            }
            
            if (size.width > size.height) {
                width = 150;
                height = 150.0 / size.width * size.height;
            }else {
                height = 150;
                width = 150.0 / size.height * size.width;
            }
            
            CGRect bounds = weakSelf.selectImageView.bounds;
            bounds.size = CGSizeMake(width * scale, height * scale);
            weakSelf.selectImageView.bounds = bounds;
            [weakSelf addRecordJsonArray];
        }];
    };
        return cell;
}

//解决切图滑动，背景还会接受事件的bug
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_collectionView] && _collectionView.hidden == NO) {
        return NO;
    }
    
    return YES;
    
}
@end
