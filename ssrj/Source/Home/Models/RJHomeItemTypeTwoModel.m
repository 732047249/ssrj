
#import "RJHomeItemTypeTwoModel.h"

@interface RJHomeItemTypeTwoModel ()
@end

@implementation RJHomeItemTypeTwoModel
- (void)upDateLayout{
    self.commentHeight = [NSNumber numberWithFloat:0];
    self.commentOneHeight = [NSNumber numberWithFloat:0];;
    self.commentTwoHeight = [NSNumber numberWithFloat:0];;
    self.commentThreeHeight = [NSNumber numberWithFloat:0];;
//    self.descriptionHeight = [NSNumber numberWithFloat:17];;
    
//    if (self.memo.length) {
//        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
//        CGSize size = [self.memo boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-20, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//        self.descriptionHeight = @(size.height);
//    }
    
    if (self.comment.countComment.intValue == 0) {
        self.commentHeight = [NSNumber numberWithFloat:0];
        return;
    }
    CGFloat hei =  36 +40;
//    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGFloat commentCellHei = 0;
    for (int i =0; i<self.comment.commentList.count; i++) {
        RJCommentModel *itemModel = self.comment.commentList[i];
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(SCREEN_WIDTH-60, MAXFLOAT)];
        YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:itemModel.attributeText];
        
        //        CGSize size = [itemModel.comment boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-60, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        //        CGFloat ff = 87 - 18 + size.height + 1;
        CGFloat ff = 87 - 18 + textLayout.textBoundingSize.height + 1;
        if (i == 0) {
            self.commentOneHeight = @(ff);
            commentCellHei += ff;
        }else if(i ==1){
            self.commentTwoHeight = @(ff);
            commentCellHei += ff;
            
        }else if(i==2){
            self.commentThreeHeight = @(ff);
            commentCellHei += ff;
            
        }
    }
    hei += commentCellHei;
    self.commentHeight = @(hei);
    
}

@end


@implementation RJHomeTypeTwoMemberModel



@end

@implementation RJHomeItemTypeTwoShareModel


@end

@implementation HHPCCollocationPositionModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"goodsId"}];
}

@end
