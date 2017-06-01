
#import "RJAnswerFourViewController.h"
#import "RJAnswerOneViewController.h"
#import "RJAnswerTwoModel.h"
#import "CCButton.h"
@interface RJAnswerFourViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) RJAnswerTwoModel * model;
@property (strong, nonatomic) NSMutableArray * selectIdArray;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet CCButton *allLikeButton;
@end

@implementation RJAnswerFourViewController
-  (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.dataArray = [NSMutableArray array];
    self.tableView.tableFooterView = nil;
    self.selectIdArray = [NSMutableArray array];
    
//    [self.allLikeButton addTarget:self action:@selector(allLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  TrackingId
     */
    self.startButton.trackingId = [NSString stringWithFormat:@"%@&startButton",NSStringFromClass(self.class)];
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
}
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/goods/findfeatruegrouplist?quetionId=5"];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *arr = responseObject[@"data"];
                if (arr.count == 0) {
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                    return;
                }
                NSDictionary *dic = arr.firstObject;
                NSError __autoreleasing *e = nil;
                RJAnswerTwoModel *model = [[RJAnswerTwoModel alloc]initWithDictionary:dic error:&e];
                if (model) {
                    weakSelf.model = model;
                    weakSelf.dataArray = [NSMutableArray arrayWithArray:[self.model.answers copy]];
                    weakSelf.titleLabel.text = weakSelf.model.title;
                    [weakSelf.headerView setNeedsLayout];
                    [weakSelf.headerView setNeedsUpdateConstraints];
                    CGSize size = [weakSelf.headerView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
                    weakSelf.headerView.height = size.height + 1;
                    weakSelf.tableView.tableHeaderView = weakSelf.headerView;
                    
                    weakSelf.tableView.tableFooterView = weakSelf.footerView;

                    [self.selectIdArray removeAllObjects];
                    
                    if (model.answered.length) {
                        //答过题 有答案
                        NSString *str = model.answered;
                        NSArray * arr = [str componentsSeparatedByString:@","];
                        self.selectIdArray  = [NSMutableArray arrayWithArray:arr];
                        
                    }
                    [weakSelf.tableView reloadData];
                }else{
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
                
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [self.tableView.mj_header endRefreshing];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RJAnswerFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJAnswerFourTableViewCell"];
    RJSubAnswerModel *model = self.dataArray[indexPath.row];
    cell.nameLabel.text = model.name;
    cell.memoLabel.text = model.memo;
    cell.selectImage.highlighted = NO;
    if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
        cell.selectImage.highlighted = YES;
    }
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%@",NSStringFromClass(self.class),model.id];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RJSubAnswerModel *model = self.dataArray[indexPath.row];
    if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
        [self.selectIdArray removeObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
    }else{
        [self.selectIdArray addObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
        self.allLikeButton.selected = NO;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.tableView reloadData];
}
- (void)allLikeButtonAction:(CCButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.selectIdArray removeAllObjects];
    }
    [self.tableView reloadData];
}
- (void)startButtonAction:(UIButton *)sender{
    
    if (!self.selectIdArray.count ) {
        [HTUIHelper addHUDToView:self.view withString:@"请至少选择一个风格" hideDelay:2];
        return;
    }
    
    
    if (self.delegate) {
        NSString *str =[self.selectIdArray componentsJoinedByString:@","];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (str.length == 0) {
            [self.delegate answerSaveWithDictionary:dic controllerIndex:3];
        }else{
            [dic addEntriesFromDictionary:@{@"style":str}];
            [self.delegate answerSaveWithDictionary:dic controllerIndex:3];
        }
        [self.delegate nextButtonClickedWithIndex:3];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"穿衣助手第四问"];
    [TalkingData trackPageBegin:@"穿衣助手第四问"];


}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手第四问"];
    [TalkingData trackPageEnd:@"穿衣助手第四问"];

    if (self.delegate) {
        NSString *str =[self.selectIdArray componentsJoinedByString:@","];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (str.length == 0) {
            [self.delegate answerSaveWithDictionary:dic controllerIndex:3];
        }else{
            [dic addEntriesFromDictionary:@{@"style":str}];
            [self.delegate answerSaveWithDictionary:dic controllerIndex:3];
        }
    }

}
@end



@implementation RJAnswerFourTableViewCell


@end