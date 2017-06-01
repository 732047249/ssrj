
#import "RJCommentListModel.h"

@interface RJCommentListModel ()
@end

@implementation RJCommentListModel


@end



@implementation RJCommentModel
- (NSMutableAttributedString *)attributeText{
    if (!_attributeText) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:self.comment];
        text.yy_font = [UIFont systemFontOfSize:15];
        NSArray *atResults = [[self regex_At] matchesInString:self.comment options:kNilOptions range:text.yy_rangeOfAll];
        for (NSTextCheckingResult *at in atResults) {
            if (at.range.location == NSNotFound && at.range.length <= 1) continue;
            if ([text yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
                NSRange newRange = NSMakeRange(at.range.location, at.range.length -1);
                
                [text yy_setColor:[UIColor colorWithHexString:@"#1b82bd"] range:newRange];
                
                YYTextHighlight *highlight = [YYTextHighlight new];
                
                if (self.replyMember.memberId) {
                    highlight.userInfo = @{@"memberId":self.replyMember.memberId};
                }
                [text yy_setTextHighlight:highlight range:newRange];

            }
        }
        _attributeText = text;
    }
    return _attributeText;
}

- (NSRegularExpression *)regex_At{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5].*:" options:kNilOptions error:NULL];
    return regex;
}
@end


@implementation RJCommentMemberModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"memberId"}];
}

@end