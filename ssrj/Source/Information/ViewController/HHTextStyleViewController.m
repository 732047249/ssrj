//
//  HHTextStyleViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHTextStyleViewController.h"
#import "HHTextStyleCell.h"
#import "Masonry.h"

@interface HHTextStyleViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UITableView *textStyleTabelView;
@property (nonatomic, strong) NSArray *titleArray;
@end

@implementation HHTextStyleViewController
{
    BOOL _paragraphType;
    BOOL _shouldScrollToSelectedRow;
    BOOL _needReload;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textStyleTabelView = [[UITableView alloc] init];
    _textStyleTabelView.delegate = self;
    _textStyleTabelView.dataSource = self;
    _textStyleTabelView.tableFooterView = [UIView new];
    [self.view addSubview:_textStyleTabelView];
    if ([_textStyleTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
        _textStyleTabelView.separatorInset = UIEdgeInsetsZero;
    }
    if ([_textStyleTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
        _textStyleTabelView.layoutMargins = UIEdgeInsetsZero;
    }
    [_textStyleTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _titleArray = @[@"大标题",@"小标题",@"正文",@"无序列表"];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_needReload) {
        [self reload];
    }
}
- (void)reload {
    [self.textStyleTabelView reloadData];
    _needReload = NO;
}

#pragma mark - setTextStyle

- (void)setTextStyle:(LMTextStyle *)textStyle {
    _textStyle = textStyle;
    _needReload = YES;
}
//#pragma mark - setParagraph
//
//- (void)setParagraphConfig:(LMParagraphConfig *)paragraphConfig {
//    _paragraphType = paragraphConfig.type;
//    _needReload = YES;
//}

#pragma mark - tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.textStyle) {
        return 0;
    }
    return _titleArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HHTextStyleCell *cell = (HHTextStyleCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HHTextStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [cell setLayoutMargins:UIEdgeInsetsZero];
            
        }
    }
    cell.nameLabel.text = _titleArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.nameLabel.font = [UIFont systemFontOfSize:20];
    }else if (indexPath.row == 1) {
        cell.nameLabel.font = [UIFont systemFontOfSize:17];
    }else if (indexPath.row == 2) {
        cell.nameLabel.font = [UIFont systemFontOfSize:14];
    }else {
        cell.nameLabel.font = [UIFont systemFontOfSize:14];
    }
    
    //设置目前的选中行样式
    if (self.textStyle.type != 0 && self.textStyle.type == indexPath.row + 1) {
        [self.textStyleTabelView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        cell.nameLabel.textColor = APP_BASIC_COLOR2;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    HHTextStyleCell *cell = (HHTextStyleCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.nameLabel.textColor = [UIColor blackColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size.height / self.titleArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HHTextStyleCell *cell = (HHTextStyleCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.nameLabel.textColor = APP_BASIC_COLOR2;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yf_didChangedTextStyle:)]) {
        
        LMTextStyle *style = [LMTextStyle textStyleWithType:indexPath.row + 1];
        [self.delegate yf_didChangedTextStyle:style];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
