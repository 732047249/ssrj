//
//  AddDestinationTableViewController.h
//  ssrj
//
//  Created by app on 16/6/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJAddressModel.h"

@protocol AddDestinationTableViewControllerDelegate <NSObject>

- (void)reloadDestinationData;

@end

@interface AddDestinationTableViewController : UITableViewController
@property (assign, nonatomic) id<AddDestinationTableViewControllerDelegate> delegate;
@property (strong, nonatomic) RJAddressModel *addressModel;
@end


@interface RJTextView : UITextView
@property (weak, nonatomic) IBOutlet UILabel *placehoderLabel;
@end