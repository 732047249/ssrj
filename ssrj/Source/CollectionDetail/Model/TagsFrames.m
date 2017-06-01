//
//  TagsFrames.m
//  ssrj
//
//  Created by MFD on 16/7/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "TagsFrames.h"

@implementation TagsFrames
- (instancetype)init{
    self = [super init];
    if (self) {
        _tagsFrames = [NSMutableArray array];
        _tagsMargin = 10;
        _tagsLineSpacing = 10;
        _tagsMinPadding = 10;
    }
    return self;
}


- (void)setTitlesArray:(NSArray *)titlesArray{

    _titlesArray = titlesArray;
    /**
     *  清除旧的frame
     */
    [_tagsFrames removeAllObjects];
    
    CGFloat btnX = _tagsMargin;
    CGFloat btnW = 0;
    
    //下一个标签的宽度
    CGFloat nextWidth = 0;
    //每一行多出的宽度
    CGFloat moreWidth = 0;
    
    //每一行最后一个tag索引的数组
    NSMutableArray *lastIndexs = [NSMutableArray array];
    //每一行多出来的宽度数组
    NSMutableArray *moreWidths = [NSMutableArray array];
    
    for (NSInteger i=0; i<_titlesArray.count; i++) {
        btnW = [self sizeWithTitle:_titlesArray[i] font:Tags_Font].width + _tagsMinPadding*2;
        nextWidth = 0;
        if (i < _titlesArray.count -1) {
            nextWidth = [self sizeWithTitle:_titlesArray[i+1] font:Tags_Font].width + _tagsMinPadding*2;
        }
        
        CGFloat nextBtnX = btnX +btnW +_tagsMargin;
        //如果下一个按钮，标签最右边则换行
        if ((nextWidth +nextBtnX) > (SCREEN_WIDTH - _tagsMargin)) {
            moreWidth = SCREEN_WIDTH - nextBtnX;
            
            [lastIndexs addObject:[NSNumber numberWithInteger:i]];
            [moreWidths addObject:[NSNumber numberWithInteger:moreWidth]];
            
            btnX = _tagsMargin;
        }else{
            btnX += (btnW + _tagsMargin);
        }
        
        //如果是最后一个且数组中没有，则把最后一个加入到数组中
        if (titlesArray.count-1 == i) {
            if (![lastIndexs containsObject:[NSNumber numberWithInteger:i]]) {
                [lastIndexs addObject:[NSNumber numberWithInteger:i]];
                [moreWidths addObject:[NSNumber numberWithInteger:0]];
            }
        }
    }
    
    
    NSInteger location = 0; //截取的位置
    NSInteger length = 0;   //截取的长度
    CGFloat averageW = 0;   //多出来的平均宽度
    
    CGFloat tagW = 0;
    CGFloat tagH = 30;
    
    
    for (NSInteger i=0; i < lastIndexs.count; i++) {
        NSInteger lastIndex = [lastIndexs[i] integerValue];
        if (0 == i) {
            length = lastIndex + 1;
        }else{
            length = [lastIndexs[i] integerValue] - [lastIndexs[i-1] integerValue];
        }
        
        //从数组中取出每一行的数组
        NSArray *newArr = [titlesArray subarrayWithRange:NSMakeRange(location, length)];
        location = lastIndex + 1;
        
        averageW = [moreWidths[i] floatValue]/newArr.count;
        
        CGFloat tagX = _tagsMargin;
        CGFloat tagY = _tagsLineSpacing + (_tagsLineSpacing + tagH)*i;
        
        for (NSInteger j = 0; j<newArr.count; j++) {
            tagW = [self sizeWithTitle:newArr[j] font:Tags_Font].width + _tagsMinPadding*2 +averageW;
            
            CGRect btnFrame = CGRectMake(tagX, tagY, tagW, tagH);
            
            [_tagsFrames addObject:NSStringFromCGRect(btnFrame)];
            
            tagX += (tagW + _tagsMargin);
        }
    }
    
    _tagsHeight = (tagH + _tagsLineSpacing)*lastIndexs.count +_tagsLineSpacing;
}


- (CGSize)sizeWithTitle:(NSString *)title font:(UIFont *)font{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [title sizeWithAttributes:attrs];
}


@end
