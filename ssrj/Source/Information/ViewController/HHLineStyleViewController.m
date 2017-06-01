//
//  HHLineStyleViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHLineStyleViewController.h"
#import "HHLineStyleCell.h"
#import "Masonry.h"
@interface HHLineStyleViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *lineSyleTabelView;
@property (nonatomic, strong) NSArray *lineArray;
@end

@implementation HHLineStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _lineSyleTabelView = [[UITableView alloc] init];
    _lineSyleTabelView.delegate = self;
    _lineSyleTabelView.dataSource = self;
    if ([self.lineSyleTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
        _lineSyleTabelView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.lineSyleTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
        _lineSyleTabelView.layoutMargins = UIEdgeInsetsZero;
    }
    _lineSyleTabelView.tableFooterView = [UIView new];
    [self.view addSubview:_lineSyleTabelView];
    [_lineSyleTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _lineArray = @[@"infor_line_640_1",@"infor_line_640_2",@"infor_line_640_3",@"infor_line_640_4",@"infor_line_640_5",@"infor_line_640_6",@"infor_line_640_7",@"infor_line_640_8"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lineArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHLineStyleCell *cell = (HHLineStyleCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HHLineStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    HHImageStyle *imageStyle = [HHImageStyle imageStyleWithType:HHImageStyleTypeLine];
    imageStyle.ID = (int)indexPath.row;
    imageStyle.image = GetImage(_lineArray[indexPath.row]);
    cell.imageStyle = imageStyle;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HHLineStyleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(yf_didSelectLineStyle:)]) {
        [self.delegate yf_didSelectLineStyle:cell.imageStyle];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
