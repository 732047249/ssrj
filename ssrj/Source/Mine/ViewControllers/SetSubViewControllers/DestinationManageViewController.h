//
//  DestinationManageViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYLabel.h"
#import "RJBasicViewController.h"

@class DestinationModel;
@protocol DestinationManageViewControllerDelegate <NSObject>

- (void)reloadDestinationDataWithDestinationModel:(DestinationModel *)model;

@end


@interface DestinationManageViewController : RJBasicViewController

@property (weak, nonatomic) id<DestinationManageViewControllerDelegate> destinationDelegate;

@end



@interface DestinationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;

@property (weak, nonatomic) IBOutlet UIButton *editorButton;

@property (weak, nonatomic) IBOutlet YYLabel *yyLabel;

@property (weak, nonatomic) IBOutlet UIButton *toEditDestinationButton;



@end



@interface DestinationModel : JSONModel

@property (strong, nonatomic) NSNumber *id;

@property (strong, nonatomic) NSString <Optional> * areaName;

@property (strong, nonatomic) NSString <Optional> * phone;

@property (strong, nonatomic) NSString <Optional> * address;
//收货人
@property (strong, nonatomic) NSString <Optional> * consignee;

@property (strong, nonatomic) NSString <Optional> * fullName;

@property (strong, nonatomic) NSNumber <Optional> * areaId;

//@property (strong, nonatomic) NSString <Optional> * treePath;

@property (strong, nonatomic) NSString <Optional> * zipCode;

@property (strong, nonatomic) NSNumber *isDefault;


@end