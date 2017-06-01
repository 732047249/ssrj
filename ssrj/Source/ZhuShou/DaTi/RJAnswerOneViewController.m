
#import "RJAnswerOneViewController.h"
#import "CartOrBuyViewController.h"
@interface RJAnswerOneViewController ()<RJZhushouPickerViewDelegate>
@property (strong, nonatomic) AnswerOneJsonModel * model;
@end

@implementation RJAnswerOneViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"购衣助手";
    
    [self addBackButton];
    
//    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"alert_error_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemClicked)];
//    
//    self.navigationItem.leftBarButtonItem = backBarButton;
    
    
    NSMutableArray *weightArr = [NSMutableArray array];
    for (int i= 30; i<=100; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        [weightArr addObject:num];

    }
    self.weightPicker = [[RJZhushouPickerView alloc]initWithDataArray:weightArr unitStr:@"KG" defaultRow:50-30];
    self.weightPicker.delegate = self;
    
    NSMutableArray *heightArr = [NSMutableArray array];
    for (int i= 130; i<=200; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        [heightArr addObject:num];
    }
    self.heightPicker = [[RJZhushouPickerView alloc]initWithDataArray:heightArr unitStr:@"CM" defaultRow:165-130];
    self.heightPicker.delegate = self;
    
    NSMutableArray *bustArray = [NSMutableArray array];
    for (int i= 30; i<=120; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        [bustArray addObject:num];
    }
    self.bustPicker = [[RJZhushouPickerView alloc]initWithDataArray:bustArray unitStr:@"CM" defaultRow:85-30];
    self.bustPicker.delegate = self;
    
    NSMutableArray *waitsArray = [NSMutableArray array];
    for (int i= 30; i<=120; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        [waitsArray addObject:num];
    }
    self.waitsPicker = [[RJZhushouPickerView alloc]initWithDataArray:waitsArray unitStr:@"CM" defaultRow:65-30];
    self.waitsPicker.delegate = self;
    
    NSMutableArray *hiplineArr = [NSMutableArray array];
    for (int i= 30; i<=120; i++) {
        NSNumber *num = [NSNumber numberWithInt:i];
        [hiplineArr addObject:num];
    }
    self.hiplinePicker = [[RJZhushouPickerView alloc]initWithDataArray:hiplineArr unitStr:@"CM" defaultRow:90-30];
    self.hiplinePicker.delegate = self;
    
    
    self.waitsLabel.text = @"";
    self.heightsLabel.text = @"";
    self.weightLable.text = @"";
    self.bustLabel.text = @"";
    self.hiplineLabel.text = @"";
    [self getNetData];
    

}
- (void)getNetData{
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/goods/findfeatruegrouplist?quetionId=1"];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                self.model = [[AnswerOneJsonModel alloc]initWithDictionary:dic error:nil];
                if (self.model) {
                    self.weightLable.text = @"我不清楚";
                    self.weightLable.highlighted = NO;
                    if (self.model.weight) {
                        self.weight = self.model.weight.integerValue;
                        self.weightLable.text = [NSString stringWithFormat:@"%ldkg",(long)self.weight];
                        self.weightLable.highlighted = YES;
                    }
                    self.heightsLabel.text = @"我不清楚";
                    self.heightsLabel.highlighted = NO;
                    if (self.model.heights) {
                        self.height = self.model.heights.integerValue;
                        self.heightsLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.height];
                        self.heightsLabel.highlighted = YES;
                        
                    }
                    self.bustLabel.text = @"我不清楚";
                    self.bustLabel.highlighted = NO;
                    if (self.model.bust) {
                        self.bust = self.model.bust.integerValue;
                        self.bustLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.bust];
                        self.bustLabel.highlighted = YES;
                        
                    }
                    self.waitsLabel.text = @"我不清楚";
                    self.waitsLabel.highlighted = NO;
                    if (self.model.waist) {
                        self.waits = self.model.waist.integerValue;
                        self.waitsLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.waits];
                        self.waitsLabel.highlighted = YES;
                        
                    }
                    self.hiplineLabel.text = @"我不清楚";
                    self.hiplineLabel.highlighted = NO;
                    if (self.model.hipline) {
                        self.hipline = self.model.hipline.integerValue;
                        self.hiplineLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.hipline];
                        self.hiplineLabel.highlighted = YES;
                        
                    }
                }
                [[HTUIHelper shareInstance]removeHUD];
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
}

#pragma mark --添加返回按钮
- (void)addBackButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+20, buttonImg.size.height);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button setImage:buttonImg forState:0];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
}
#pragma mark --自定义返回按钮点击事件
- (void)back:(UIButton *)button {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backBarButtonItemClicked {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"穿衣助手问题一"];
    [TalkingData trackPageBegin:@"穿衣助手问题一"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手问题一"];
    [TalkingData trackPageEnd:@"穿衣助手问题一"];


//    if (self.delegate) {
//        NSMutableDictionary *dic =[NSMutableDictionary dictionary];
//        if (self.weight != 0) {
//            
//            [dic addEntriesFromDictionary:@{@"weight":[NSNumber numberWithInteger:self.weight]}];
//        }
//        if (self.height != 0) {
//            
//            [dic addEntriesFromDictionary:@{@"heights":[NSNumber numberWithInteger:self.height]}];
//        }
//        if (self.bust != 0) {
//            
//            [dic addEntriesFromDictionary:@{@"bust":[NSNumber numberWithInteger:self.bust]}];
//        }
//        if (self.waits != 0) {
//            
//            [dic addEntriesFromDictionary:@{@"waist":[NSNumber numberWithInteger:self.waits]}];
//        }
//        if (self.hipline != 0) {
//            
//            [dic addEntriesFromDictionary:@{@"hipline":[NSNumber numberWithInteger:self.hipline]}];
//        }
//        [self.delegate answerSaveWithDictionary:dic controllerIndex:0];
//    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self.weightPicker showPickerView];
            break;
        case 1:
            [self.heightPicker showPickerView];
            break;
        case 2:
            [self.bustPicker showPickerView];
            break;
        case 3:
            [self.waitsPicker showPickerView];
            break;
        case 4:
            [self.hiplinePicker showPickerView];
            break;
        default:
            break;
    }
}

#pragma mark - RJZhushouPickerViewDelegate
#pragma mark
- (void)didSelectDataWithInteger:(NSInteger ) data unitStr:(NSString *)unit pickerView:(RJZhushouPickerView *)view{
    if (view == self.weightPicker) {
        self.weight = data;
        self.weightLable.text = [NSString stringWithFormat:@"%ldkg",(long)self.weight];
        self.weightLable.highlighted = YES;
    }
    if (view == self.heightPicker) {
        self.height = data;
        self.heightsLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.height];
        self.heightsLabel.highlighted = YES;
    }
    if (view == self.bustPicker) {
        self.bust = data;
        self.bustLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.bust];
        self.bustLabel.highlighted = YES;
        ;
    }
    if (view == self.waitsPicker) {
        self.waits = data;
        self.waitsLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.waits];
        self.waitsLabel.highlighted = YES;
    }
    if (view == self.hiplinePicker) {
        self.hipline = data;
        self.hiplineLabel.text = [NSString stringWithFormat:@"%ldcm",(long)self.hipline];
        self.hiplineLabel.highlighted = YES;
    }
}
- (void)clearDataUnitStr:(NSString *)unit pickerView:(RJZhushouPickerView *)view{
    if (view == self.weightPicker) {
        
        self.weightLable.text = @"我不清楚";
        self.weightLable.highlighted = NO;
        self.weight = 0;
    }
    if (view == self.heightPicker) {

        self.heightsLabel.text = @"我不清楚";
        self.heightsLabel.highlighted = NO;
        self.height = 0;
        
    }
    if (view == self.bustPicker) {

        self.bustLabel.text = @"我不清楚";
        self.bustLabel.highlighted = NO;
        self.bust = 0;
    }
    if (view == self.waitsPicker) {

        self.waitsLabel.text = @"我不清楚";
        self.waitsLabel.highlighted = NO;
        self.waits = 0;
    }
    if (view == self.hiplinePicker) {

        self.hiplineLabel.text = @"我不清楚";
        self.hiplineLabel.highlighted = NO;
        self.hipline = 0;
    }
}
- (IBAction)nextButtonAction:(id)sender {
//    if (self.delegate) {
//        [self.delegate  nextButtonClickedWithIndex:0];
//    }
    [HTUIHelper addHUDToWindowWithString:@"保存中..."];
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    if (self.weight != 0) {
        
        [dic addEntriesFromDictionary:@{@"weight":[NSNumber numberWithInteger:self.weight]}];
    }
    if (self.height != 0) {
        
        [dic addEntriesFromDictionary:@{@"heights":[NSNumber numberWithInteger:self.height]}];
    }
    if (self.bust != 0) {
        
        [dic addEntriesFromDictionary:@{@"bust":[NSNumber numberWithInteger:self.bust]}];
    }
    if (self.waits != 0) {
        
        [dic addEntriesFromDictionary:@{@"waist":[NSNumber numberWithInteger:self.waits]}];
    }
    if (self.hipline != 0) {
        
        [dic addEntriesFromDictionary:@{@"hipline":[NSNumber numberWithInteger:self.hipline]}];
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/clad-aide/addstylefeatrueuser"];
    [requestInfo.getParams addEntriesFromDictionary:[dic copy]];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                [HTUIHelper removeHUDToWindowWithEndString:@"保存成功" image:nil delyTime:1];
                
                if ([self.delegate isKindOfClass:[CartOrBuyViewController class]]) {
                    
                    if ([self.delegate respondsToSelector:@selector(saveRecommentedSizeInfo)]) {
                        
                        [self.delegate saveRecommentedSizeInfo];
                    }
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else if(state.intValue == 1){
                [HTUIHelper removeHUDToWindowWithEndString:responseObject[@"msg"] image:nil delyTime:1];
            }
        }else{
            [HTUIHelper removeHUDToWindowWithEndString:@"error" image:nil delyTime:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindowWithEndString:[error localizedDescription] image:nil delyTime:1];

    }];
}

@end


@implementation AnswerOneJsonModel


@end
