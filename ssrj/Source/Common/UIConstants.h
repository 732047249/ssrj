//
//  UIConstants.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

//#ifndef UIConstants_h
//#define UIConstants_h


#define APP_BASIC_COLOR [UIColor colorWithHexString:@"#190d31"]
#define APP_BASIC_COLOR2 [UIColor colorWithHexString:@"#5D32B5"]

#define APP_BASIC_YELLOW_COLOR [UIColor colorWithHexString:@"#ffd045"]

#define APP_BASIC_TEXT_COLOR [UIColor colorWithHexString:@"#999999"]

#define APP_BASIC_TEXT_LIGHT_COLOR [UIColor colorWithHexString:@"#aeaeae"]

#define APP_BASIC_BG_COLOR [UIColor colorWithHexString:@"#434446"]

#define APP_BASIC_SELECT_COLOR [UIColor colorWithHexString:@"#bf1234"]

#define APP_BASIC_CELL_COLOR [UIColor colorWithHexString:@"#3c3d3f"]


#define CELL_BG_COLOR_0 [UIColor colorWithHexString:@"#d99790"]

#define CELL_BG_COLOR_1 [UIColor colorWithHexString:@"#d59fa2"]

#define CELL_BG_COLOR_2 [UIColor colorWithHexString:@"#f5e2d5"]

#define CELL_BG_COLOR_3 [UIColor colorWithHexString:@"#f3c1b5"]



#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_MAX      MAX(SCREEN_HEIGHT,SCREEN_WIDTH)
#define SCREEN_MIN      MIN(SCREEN_HEIGHT,SCREEN_WIDTH)

#define UI_NAVIGATION_BAR_HEIGHT    44
#define UI_TAB_BAR_HEIGHT           49
#define UI_STATUS_BAR_HEIGHT        20

#define SIDE_MENU_WIDTH             240

#define UI_TEXT_PRIMARY_COLOR               [UIColor colorWithHexString:@"#888888"]
#define UI_TEXT_SECONDARY_COLOR             [UIColor colorWithHexString:@"#333333"]
#define TABLEVIEW_ITEM_SELECTED_BG_COLOR    [UIColor colorWithHexString:@"#cad6d6"]

#define UI_BACKGROUND_COLOR                 [UIColor colorWithHexString:@"#efeff4"]
#define UI_FIRST_COLOR                      [UIColor colorWithHexString:@"#f89a04"]
#define UI_SECOND_COLOR                     [UIColor colorWithHexString:@"#828a8d"]
#define UI_THIRD_COLOR                      [UIColor colorWithHexString:@"#4e555b"]
#define UI_FOURTH_COLOR                     [UIColor colorWithHexString:@"#ececec"]
#define UI_FIFTH_COLOR                      [UIColor colorWithHexString:@"#a3a3a3"]

#define UI_POPOVER_LINE1_COLOR              [UIColor colorWithHexString:@"#7b7e81"]
#define UI_POPOVER_LINE2_COLOR
#define BUTTON_BORDER_COLOR                 [UIColor colorWithHexString:@"#3DBB92"]

#define UI_LABEL_LENGTH             200
#define UI_LABEL_HEIGHT             15
#define UI_LABEL_FONT_SIZE          12
#define UI_LABEL_FONT               [UIFont systemFontOfSize:UI_LABEL_FONT_SIZE]
#define TITLE_BAR_HEIGHT            44
#define NAVITEM_SIZE                44

#define MAIN_MAPVIEW_TOOLBOX_HEIGHT 144



#ifndef CCInitializingRootForUIView
#define CCInitializingRootForUIView \
- (instancetype)init {\
self = [super init];\
if (self) {\
[self onInit];\
[self performSelector:@selector(afterInit) withObject:self afterDelay:0];\
}\
return self;\
}\
- (instancetype)initWithFrame:(CGRect)frame {\
self = [super initWithFrame:frame];\
if (self) {\
[self onInit];\
[self performSelector:@selector(afterInit) withObject:self afterDelay:0];\
}\
return self;\
}\
- (instancetype)initWithCoder:(NSCoder *)aDecoder {\
self = [super initWithCoder:aDecoder];\
if (self) {\
[self onInit];\
[self performSelector:@selector(afterInit) withObject:self afterDelay:0];\
}\
return self;\
}

#endif

//#endif /* UIConstants_h */
