//
//  SMAddTagViewController.m
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAddTagViewController.h"
#import "SMMatchDiscriptController.h"
#import "SMPublishMatchController.h"
#import "SMAddTagCell.h"
#import "Masonry.h"
@interface SMAddTagViewController ()<EditImageViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
/** 面板 */
@property (nonatomic,strong)EditImageView *imageView;
/** 底部的单品列表 */
@property (nonatomic,strong)UICollectionView *collectionView;
/** 记录编辑标签的位置 */
@property (nonatomic,assign)CGPoint tapPoint;
/** 记录编辑中的标签 */
@property (nonatomic,strong)TagView *tagView;
/** 底部的单品列表为空时hidden = NO */
@property (nonatomic,strong)UILabel *empertyLabel;
@end

@implementation SMAddTagViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"上传搭配页面"];
    [TalkingData trackPageBegin:@"上传搭配页面"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"上传搭配页面"];
    [TalkingData trackPageEnd:@"上传搭配页面"];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self configMatchView];
    [self configCollectionView];
    [self configNavBar];
}
#pragma mark - 对外接口
#pragma mark -- 添加标签
/**    model :
 _isAddTag = YES
 _tagText = Sophyline黑色过膝半身裙
 _direction = TagDirectionTypeLeft
 _goodsId = 274
 _brandId = 72
 _goodsModel =
     <SMGoodsModel>
     [brand_name]: Sophyline
     [price]: 273
     [market_price]: 328
     [image]: http://www.ssrj.com/upload/image/201611/256e906b-718b-46e6-...
     [brand]: 72
     [name]: 黑色过膝半身裙
     [ID]: 274
     </SMGoodsModel>
 */
- (void)addTagWithTagModel:(TagModel *)model {
    //添加标签
    if (model.isAddTag) {
        model.point = self.tapPoint;
        model.direction = TagDirectionTypeLeft;
        [self.imageView addTagWithModel:model];
    }
    //修改标签
    else {
        model.point = self.tagView.model.point;
        model.direction = self.tagView.model.direction;
        self.tagView.model = model;
    }
    [self.collectionView reloadData];
    [self hiddenOrShowEmpertyLabel];
}
#pragma mark - UI
- (void) configNavBar{
    [self setTitle:@"搭配" tappable:NO];
    [self addBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(clickNextBtn:)];
}
/** 面板 */
- (void)configMatchView {
    self.imageView = [EditImageView editViewWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    self.imageView.image = self.image;
    self.imageView.delegate = self;
    [self.view addSubview:self.imageView];
}
/** 底部单品列表和空时占位图 */
- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(160, 180);
    layout.minimumLineSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[SMAddTagCell class] forCellWithReuseIdentifier:@"tagCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.imageView.mas_bottom);
        make.height.mas_equalTo(180);
    }];
    self.empertyLabel = [[UILabel alloc] init];
    self.empertyLabel.text = @"点击图片\n选择添加相关单品信息";
    self.empertyLabel.textColor = [UIColor grayColor];
    self.empertyLabel.textAlignment = NSTextAlignmentCenter;
    self.empertyLabel.numberOfLines = 2;
    [self.view addSubview:self.empertyLabel];
    [self.empertyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.imageView.mas_bottom);
        make.height.mas_equalTo(180);
    }];

}
#pragma mark - event
//重写返回
- (void)back:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否放弃当前操作？" preferredStyle:UIAlertControllerStyleAlert];
    //返回到tabbarController
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

/**drafDict
 {
 data =     (
 {
 pointX = "11.59687499999995";
 pointY = 116;
 direction = 0;
 tagText = "Tahari by ASL\U6df1\U84dd\U8272\U957f\U8896\U9576\U94bb\U540e\U5f00\U53c9\U8d85\U957f\U8fde\U8863\U88d9";
 screenWidth = 375;
 }
 );
 }
 */
/** 下一步：发布 */
- (void)clickNextBtn:(UIButton *)sender {
    if (self.imageView.tagViewArray.count == 0) {
        [HTUIHelper addHUDToWindowWithString:@"请添加单品" hideDelay:1];
    }else if (self.imageView.tagViewArray.count > 6) {
        [HTUIHelper addHUDToWindowWithString:@"最多添加6个单品" hideDelay:1];
    }
    else {
        //判断用户是否登录
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return;
        }
        NSMutableArray *goodsArr = [NSMutableArray array];
        NSMutableArray *draftArr = [NSMutableArray array];
        for (TagView *tagView in self.imageView.tagViewArray) {
            
            TagModel *model = tagView.model;
            if (!model.goodsId.length) {
                continue;
            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            //标签左边的中心点位置，方向，屏幕宽度
            [dict setObject:@(model.point.x) forKey:@"pointX"];
            [dict setObject:@(model.point.y) forKey:@"pointY"];
            //position == 0 箭头向左
            [dict setObject:@(model.direction) forKey:@"direction"];
            [dict setObject:model.tagText forKey:@"tagText"];
            [dict setObject:@(kScreenWidth) forKey:@"screenWidth"];
            [dict setObject:model.goodsId forKey:@"id"];
            
            [goodsArr addObject:model.goodsId];
            [draftArr addObject:dict];
            
        }
        NSDictionary *draftDict = @{@"data" : draftArr};
        NSData *data = [NSJSONSerialization dataWithJSONObject:draftDict options:0 error:nil];
        NSString *draftString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        SMPublishMatchController *publish = [[SMPublishMatchController alloc]init];
        publish.image = self.image;
        publish.jsonString = draftString;
        publish.goodsIdArr = goodsArr;
        publish.publishType = SMPublishTypeTag;
        [self.navigationController pushViewController:publish animated:YES];
    }
}

#pragma mark - <EditImageViewDelegate>

//修改标签
- (void)didEditTagView:(TagView *)tagView {
    self.tagView = tagView;
    SMMatchDiscriptController *matchDiscriptController = [[SMMatchDiscriptController alloc] init];
    matchDiscriptController.isAddTag = NO;
    [self.navigationController pushViewController:matchDiscriptController animated:YES];
}
//添加标签
- (void)didTapEditTagViewWithTapPoint:(CGPoint)point {
    if (self.imageView.tagViewArray.count >= 6) {
        [HTUIHelper addHUDToWindowWithString:@"最多添加6个单品" hideDelay:1];
        return;
    }
    self.tapPoint = point;
    SMMatchDiscriptController *matchDiscriptController = [[SMMatchDiscriptController alloc] init];
    matchDiscriptController.isAddTag = YES;
    [self.navigationController pushViewController:matchDiscriptController animated:YES];
}
//长按标签
- (void)didLongPressTagView:(TagView *)tagView {
    [self deleteTagView:tagView];
}
//删除标签
- (void)deleteTagView:(TagView *)tagView {
    [tagView removeFromSuperview];
    [self.imageView.tagViewArray removeObject:tagView];
    [self.collectionView reloadData];
    [self hiddenOrShowEmpertyLabel];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageView.tagViewArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagView *tagView = self.imageView.tagViewArray[indexPath.row];
    SMAddTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    cell.model = tagView.model.goodsModel;
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),tagView.model.goodsModel.ID.intValue];

    __weak __typeof(&*self)weakSelf = self;
    cell.deleteBlock = ^(){
        TagView *tagView = weakSelf.imageView.tagViewArray[indexPath.row];
        [weakSelf deleteTagView:tagView];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)hiddenOrShowEmpertyLabel {
    if (self.imageView.tagViewArray.count == 0) {
        self.empertyLabel.hidden = NO;
    }else {
        self.empertyLabel.hidden = YES;
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
