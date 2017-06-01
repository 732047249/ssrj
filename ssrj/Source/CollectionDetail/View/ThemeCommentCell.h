//
//  ThemeCommentCell.h
//  ssrj
//
//  Created by MFD on 16/9/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYLabel.h"
#import "RecommendCollectionsModel.h"
#import "YYLabelLayoutModel.h"
@protocol  CommentCellDelegate<NSObject>
@optional
- (void)celldidClickUser:(CommentListModel *) commentListModel;

- (void)celldidClickLabel:(YYLabel *)label textRange:(NSRange)textRange indexPath:(NSIndexPath *)indexPath;
@end



@interface ThemeCommentCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView* icon;

@property (nonatomic,strong)UIView* commentView;

@property (nonatomic,strong)UILabel* authorLabel;

@property (nonatomic,strong)YYLabel* commentLabel;

@property (nonatomic,strong)UILabel* dateLabel;

@property (nonatomic,strong)UIButton* deleteButton;

@property (nonatomic,strong)UIView* sepLine;

@property (nonatomic,strong)CommentListModel *commentListModel;

@property (nonatomic,strong)id<CommentCellDelegate> delegate;

@property (nonatomic,strong)NSIndexPath* indexPath;

@property (nonatomic,strong)YYLabelLayoutModel *yyLabelLayoutModel;

@end
