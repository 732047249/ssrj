//
//  AddAddressViewController.h
//  ssrj
//
//  Created by CC on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJAddressModel.h"
@protocol AddAddressDelegate <NSObject>
- (void)reloadNetData;
@end

@interface AddAddressViewController : UITableViewController
@property (assign, nonatomic) id<AddAddressDelegate> delegate;
@property (strong, nonatomic) RJAddressModel * addressModel;
@end




@interface CCTextView : UITextView
@property (weak, nonatomic) IBOutlet  UILabel *placehoderLabel;
@end