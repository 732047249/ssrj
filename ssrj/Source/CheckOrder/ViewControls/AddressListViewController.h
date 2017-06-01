//
//  AddressListViewController.h
//  ssrj
//
//  Created by CC on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "SWTableViewCell.h"
#import "YYLabel.h"
#import "RJAddressModel.h"

@protocol AddressListDelegate <NSObject>
- (void)choseAddressWithModel:(RJAddressModel *)model;
@end

@interface AddressListViewController : RJBasicViewController
@property (strong, nonatomic) RJAddressModel * model;
@property (assign, nonatomic) id<AddressListDelegate> deleagte;
@end




@interface AddressListTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton  *editButton;
@property (assign, nonatomic) BOOL  isDefault;
@property (assign, nonatomic) BOOL  isSelected;
@property (weak, nonatomic) IBOutlet YYLabel *yyLabel;
- (void)showSelectedLine;
- (void)hideSelectedLine;
@end

