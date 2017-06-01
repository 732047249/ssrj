//
//  CollectionsAddCartVC.m
//  ssrj
//
//  Created by MFD on 16/7/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CollectionsAddCartVC.h"
#import "CollectionsAddCartVC_Cell.h"

@interface CollectionsAddCartVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation CollectionsAddCartVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CollectionsAddCartVC_Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionsAddCartVC_Cell" forIndexPath:indexPath];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}

@end

