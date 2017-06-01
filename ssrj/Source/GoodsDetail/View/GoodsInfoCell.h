//
//  GoodsInfoCell.h
//  ssrj
//
//  Created by MFD on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GoodsInfoCellDelegate <NSObject>

- (void) cellFinishLoadedWithWebViewHeight:(CGFloat)height;
@end

@interface GoodsInfoCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIWebView *goosInfoWebView;
@property (nonatomic,strong) NSString *contentStr;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,weak) id<GoodsInfoCellDelegate> delegate;
@end

