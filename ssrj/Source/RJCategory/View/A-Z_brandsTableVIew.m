//
//  A-Z_brandsTableVIew.m
//  categoryDemo
//
//  Created by MFD on 16/5/25.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "A-Z_brandsTableVIew.h"
#import "BrandsTableViewCell.h"
#import "RJBrandModel.h"
#import "HomeGoodListViewController.h"

#define MFDBGCOLOR [UIColor colorWithRed:37/255.0 green:29/255.0 blue:56/255.0 alpha:0.8]
#define MFDHEADERCOLOR  [UIColor colorWithRed:65/255.0 green:31/255.0 blue:143/255.0 alpha:1]

static NSString *reuseId = @"brandsID";
@interface A_Z_brandsTableVIew()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *sectionIndexCoverView;


@end

@implementation A_Z_brandsTableVIew
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self registerNib:[UINib nibWithNibName:@"BrandsTableViewCell" bundle:nil] forCellReuseIdentifier:reuseId];
    }
//    self.backgroundColor = MFDHEADERCOLOR;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sectionIndexColor = [UIColor whiteColor];
    
//    self.sectionIndexBackgroundColor = MFDBGCOLOR;
    self.sectionIndexBackgroundColor = [UIColor clearColor];
    self.bounces = NO;
    self.alpha = 0.95;
    self.dataSource = self;
    self.delegate = self;
    return self;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    data_Model *data_model = self.brandsArray[indexPath.section];
    category_data_Model *category_data_model = data_model.category_data[indexPath.row];
    [self.brandsCellDelegate didSelectCell:@"brands" and:category_data_model.goodsId];
    [self removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = MFDHEADERCOLOR;
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:24];
    [header.textLabel setTextColor:[UIColor whiteColor]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  40;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sectionIndexArray = [NSMutableArray array];
    for (int i = 0; i < self.brandsArray.count; i++) {
        data_Model *data_model = self.brandsArray[i];
        [sectionIndexArray addObject:data_model.category];
    }
    return sectionIndexArray;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.brandsArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    data_Model *data_model = self.brandsArray[section];
    return  data_model.category_data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    data_Model *data_model = self.brandsArray[section];
    return data_model.category;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BrandsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
//    if (indexPath.row%2 == 0) {
//        cell.backgroundColor = [UIColor redColor];
//    }else{
//        cell.backgroundColor = [UIColor greenColor];
//    }
    cell.backgroundColor = [UIColor colorWithRed:37/255.0 green:29/255.0 blue:56/255.0 alpha:1];
    data_Model *data_model = self.brandsArray[indexPath.section];
    category_data_Model *category_data_Model = data_model.category_data[indexPath.row];
    cell.goodsNamelabel.text = @"";
    cell.goodsNamelabel.textColor = [UIColor whiteColor];
    
    cell.goodsBrandNamelabel.text = category_data_Model.name;
    cell.goodsBrandNamelabel.textColor = [UIColor whiteColor];
    return  cell;
}


@end
