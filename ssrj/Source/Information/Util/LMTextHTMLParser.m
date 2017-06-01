//
//  LMTextHTMLParser.m
//  SimpleWord
//
//  Created by Chenly on 16/6/27.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextHTMLParser.h"
#import "UIFont+LMText.m"
#import "HHTextAttachment.h"

@implementation LMTextHTMLParser



/**
 *  预览用
 *
 *  @param attributedString 需要被导出的富文本
 *
 *  @return 导出的 HTML
 */
+ (NSMutableString *)htmlDraftFromAttributedString:(NSAttributedString *)attributedString {
    
    BOOL isNewParagraph = YES;
    NSMutableString *htmlContent = [NSMutableString string];
    NSRange effectiveRange = NSMakeRange(0, 0);
    
    while (effectiveRange.location + effectiveRange.length < attributedString.length) {
        
        NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        HHTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        int goodsId = 1;
        int collectionId = 1;
        if (attachment) {
            CGFloat height = attachment.image.size.height;
            switch (attachment.imageStyle.type) {
                case HHImageStyleTypeLine:
                    [htmlContent appendString:[NSString stringWithFormat:@"<div align=\"center\"><img src=\"%@\" width=\"100%%\" height=\"%f\"/>",attachment.imageStyle.fileUrl,height]];
                    break;
                case HHImageStyleTypeGoods:
                    [htmlContent appendString:[NSString stringWithFormat:@"<div align=\"center\"><img id=\"goods_%.2d\" src=\"%@\" width=\"100%%\"/></div>",goodsId,attachment.imageStyle.fileUrl]];
                    goodsId++;
                    break;
                case HHImageStyleTypeMatch:
                    [htmlContent appendString:[NSString stringWithFormat:@"<div align=\"center\"><img id=\"collocation_%.2d\" src=\"%@\" width=\"100%%\"/></div>",collectionId,attachment.imageStyle.fileUrl]];
                    collectionId++;
                    break;
                case HHImageStyleTypeLibrary:
                    [htmlContent appendString:[NSString stringWithFormat:@"<div align=\"center\"><img src=\"%@\" width=\"100%%\" height=\"\"/></div>",attachment.imageStyle.fileUrl]];
                    break;
                default:
                    break;
            }
        }
        else {
            NSString *text = [[attributedString string] substringWithRange:effectiveRange];
            UIFont *font = attributes[NSFontAttributeName];
            UIColor *fontColor = attributes[NSForegroundColorAttributeName];
            NSString *color = [self hexStringWithColor:fontColor];
            BOOL hasUnderline = [attributes[NSUnderlineStyleAttributeName] boolValue];
            
            BOOL isFirst = YES;
            NSArray *components = [text componentsSeparatedByString:@"\n"];
            for (NSInteger i = 0; i < components.count; i ++) {
                
                NSString *content = components[i];
                content = [content stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp"];
                if (!isFirst && !isNewParagraph) {
                    [htmlContent appendString:@"</p>"];
                    isNewParagraph = YES;
                }
                if (isNewParagraph && (content.length > 0 || i < components.count - 1)) {
                    CGFloat leftMargin = 0;
                    
                    if (font.fontSize == 15.f && font.bold == YES) {
                        leftMargin = 2;
                    }
                    [htmlContent appendString:[NSString stringWithFormat:@"<p style=\"margin:14px 0px 14px %.fem;text-align:left;padding:0px\">",leftMargin]];
                    isNewParagraph = NO;
                }
                [htmlContent appendString:[self HTMLWithContent:content font:font underline:hasUnderline color:color]];
                isFirst = NO;
            }
            if (effectiveRange.location + effectiveRange.length >= attributedString.length && ![htmlContent hasSuffix:@"</p>"]) {
                // 补上</p>
                [htmlContent appendString:@"</p>"];
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    [htmlContent insertString:@"<div style=\"margin:0 16px 0 16px\">" atIndex:0];
    [htmlContent appendString:@"</div>"];
    return htmlContent;
}

+ (NSString *)HTMLWithContent:(NSString *)content font:(UIFont *)font underline:(BOOL)underline color:(NSString *)color {
    
    if (content.length == 0) {
        return @"";
    }
    
    if (font.bold) {
        content = [NSString stringWithFormat:@"<b>%@</b>", content];
    }
    if (font.italic) {
        content = [NSString stringWithFormat:@"<i>%@</i>", content];
    }
    if (underline) {
        content = [NSString stringWithFormat:@"<u>%@</u>", content];
    }
    NSLog(@"html-- %@",[NSString stringWithFormat:@"<font style=\"font-size:%fpx;color:%@\">%@</font>", font.fontSize, color, content]);
    return [NSString stringWithFormat:@"<font style=\"font-size:%fpx;color:%@\">%@</font>", font.fontSize, color, content];
}

+ (NSString *)hexStringWithColor:(UIColor *)color {
    
    NSString *colorString = [[CIColor colorWithCGColor:color.CGColor] stringRepresentation];
    NSArray *parts = [colorString componentsSeparatedByString:@" "];
    
    NSMutableString *hexString = [NSMutableString stringWithString:@"#"];
    for (int i = 0; i < 3; i ++) {
        [hexString appendString:[NSString stringWithFormat:@"%02X", (int)([parts[i] floatValue] * 255)]];
    }
    return [hexString copy];
}

@end
