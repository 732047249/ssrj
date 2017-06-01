//
//  HHInformationViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInformationViewController.h"
#import "HHInformationTextView.h"
#import "RJTopicCategoryModel.h"
#import "AJPhotoPickerViewController.h"
#import "UIButton+ImageTitleSpacing.h"
#import "HHSpecialTopicAlertView.h"
#import "HHSelecteGoodsOrMatchController.h"
#import "SMPublishFinishedController.h"
#import "HHLineStyleViewController.h"
#import "HHTextStyleViewController.h"
#import "HHHTMLViewController.h"
#import "HMSegmentedControl.h"
#import "Masonry.h"
#import "UIFont+LMText.h"
#import "LMTextHTMLParser.h"
#import "HHTextAttachment.h"
#import "HHInforDraftController.h"
#import "ZHALAsset.h"
#import "HHInforDraftModel.h"

static NSString * const CategoryUrl = @"/b82/api/v5/index/infromcategorylist"; //专题
//static NSString * const PublishInformationUrl = @"http://192.168.1.173:9999/api/v1/information/upload_information"; //发布
static NSString * const PublishInformationUrl = @"/b180/api/v1/information/upload_information";
static NSString * const ListString = @"•  ";

@interface HHInformationViewController ()<HHSpecialTopicAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate,AJPhotoPickerProtocol,HHTextStyleViewControllerDelegate,HHLineStyleViewControllerDelegate,HHInformationTextViewDelegate,HHInforDraftControllerDelegate>

@property (nonatomic, assign) CGFloat keyboardSpacingHeight;
@property (nonatomic, strong) NSMutableArray *specialTopicModelArr;
@property (nonatomic, assign) BOOL hasAddCoverImage;
@property (nonatomic, assign) BOOL hasSelectSpecialTopic;
@property (nonatomic, assign) BOOL isShouldBegin;

@property (nonatomic, strong) HHLineStyleViewController *lineStyleViewController;
@property (nonatomic, strong) HHTextStyleViewController *textStyleViewController;

@property (nonatomic, strong) HMSegmentedControl *contentInputAccessoryView;
@property (nonatomic, strong) HHInformationTextView *textView;
@property (nonatomic, strong) HHSpecialTopicAlertView *alertView;
@property (nonatomic, strong) UITableView *textStyleTableView;

@property (nonatomic, strong) LMTextStyle *currentTextStyle;
@property (nonatomic, strong) HHImageStyle *coverImageStyle;

@property (nonatomic, strong) RJTopicCategoryModel *selectSpacialTopicModel;
@property (nonatomic, strong) HHInforDraftModel *currentDraftModel;//当前打开的草稿

@end

@implementation HHInformationViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"创建资讯页面"];
    [TalkingData trackPageBegin:@"创建资讯页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"创建资讯页面"];
    [TalkingData trackPageEnd:@"创建资讯页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isShouldBegin = YES;
    // Do any additional setup after loading the view.
    [self configNavBar];
    [self configTextView];
    [self configAccessoryView];
    [self addNotification];
    [self getCategoryData];
    
    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
    [self updateParagraphTypingAttributes];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutTextView];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 40.f;
    self.contentInputAccessoryView.frame = rect;
}
#pragma mark - UI
- (void)configNavBar {
    
    [self addBackButton];
    self.title = @"发布资讯";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"match_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBtnClick)];
}
- (void)configTextView {
    _textView = [[HHInformationTextView alloc] init];
    _textView.delegate = self;
    _textView.clickCoverDelegate = self;
    _textView.titleTextField.delegate = self;
    [_textView.selectSpecialTopicBtn addTarget:self action:@selector(clickSelectSpecialTopicBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_textView];
}
- (void)configAccessoryView {
    NSArray *items = @[
                       [UIImage imageNamed:@"infor_ABC"],
                       [UIImage imageNamed:@"infor_tupian"],
                       [UIImage imageNamed:@"infor_zi"],
                       [UIImage imageNamed:@"infor_lianjie"],
                       [UIImage imageNamed:@"infor_fuhao"]
                       ];
    
    NSArray *selectItems = @[
                       [UIImage imageNamed:@"infor_ABC_1"],
                       [UIImage imageNamed:@"infor_tupian_1"],
                       [UIImage imageNamed:@"infor_zi_1"],
                       [UIImage imageNamed:@"infor_lianjie_1"],
                       [UIImage imageNamed:@"infor_fuhao_1"]
                       ];
    _contentInputAccessoryView = [[HMSegmentedControl alloc] initWithSectionImages:items sectionSelectedImages:selectItems];
    _contentInputAccessoryView.backgroundColor = [UIColor whiteColor];
    _contentInputAccessoryView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    _contentInputAccessoryView.backgroundColor = [UIColor whiteColor];
    _contentInputAccessoryView.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, -10, -2, -20);
    [_contentInputAccessoryView setSelectionIndicatorColor:APP_BASIC_COLOR2];

    [_contentInputAccessoryView addTarget:self action:@selector(inputAccessoryViewIndexDidChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#bbbbbb"];
    [_contentInputAccessoryView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_contentInputAccessoryView);
        make.height.mas_equalTo(1);
    }];
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorWithHexString:@"#bbbbbb"];
    [_contentInputAccessoryView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_contentInputAccessoryView);
        make.height.mas_equalTo(1);
    }];
}
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark - 外部接口

#pragma mark -- 重新创建
- (void)deleteInformation {
    /**
     1.删除 记录与当前编辑内容相关 的属性
     */
    self.currentDraftModel = nil;
    self.coverImageStyle = nil;
    self.selectSpacialTopicModel = nil;
    
    //当前的样式改成正文。
    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
    self.hasAddCoverImage = NO;
    self.hasSelectSpecialTopic = NO;
    
    /**
     2. 删除 textView页面内容
     */
    [self.textView deleteAllContent];

}

#pragma mark -- 插入图片
- (void)insertImageWithImageStyle:(HHImageStyle *)imageStyle {
    
    /**
     0. 不考虑选中多个段落
     */
    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
    if (ranges.count > 1) {
        return;
    }
    
    NSRange selectRange = _textView.selectedRange;
    
    /**
        1. 构建图片富文本
     */
    // textView 默认会有一些左右边距
    CGFloat width = CGRectGetWidth(self.textView.frame) - (self.textView.textContainerInset.left + self.textView.textContainerInset.right + 12.f);
    HHTextAttachment *textAttachment = [[HHTextAttachment alloc] init];
    CGRect rect = CGRectZero;
    rect.size.width = width;
    if (imageStyle.type == HHImageStyleTypeLine) {
        rect.size.height = imageStyle.image.size.height;
        
    }else {
        rect.size.height = width * imageStyle.image.size.height / imageStyle.image.size.width;
    }
    textAttachment.bounds = rect;
    textAttachment.image = imageStyle.image;
    imageStyle.size = rect.size;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    
    /**
     2. 构建属性字符串
     */
    
    //1.图片后的换行
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    //2.图片
    [attributedString insertAttributedString:attachmentString atIndex:0];
    //3.上一个字符不为"\n"则图片前添加一个换行
    if (_textView.selectedRange.location != 0 &&
        ![[self.textView.text substringWithRange:NSMakeRange(_textView.selectedRange.location - 1, 1)] isEqualToString:@"\n"]) {
        [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:0];
    }
    //将 换行和图片 样式设置成 当前的样式
    LMTextStyle *style = [LMTextStyle textStyleWithType:LMTextStyleFormatNormal];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName : style.paragraphStyle, NSFontAttributeName : style.font, NSForegroundColorAttributeName : style.textColor} range:NSMakeRange(0, attributedString.length)];
    
    /**
        3. 插入属性字符串
     */
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectRange withAttributedString:attributedString];
    self.textView.attributedText = attributedText;
    
    /**
        4. 重设可视区域和光标位置
     */
    //只要重设textView.attributedText 就会滚动到最底下光标页移动最后一个。所以重新设置下可视区域和selectRange
    self.textView.selectedRange = NSMakeRange(selectRange.location + attributedString.length, 0);
    [self.textView scrollRangeToVisible:NSMakeRange(selectRange.location + attributedString.length, 0)];
    
    //隐藏键盘
    if (imageStyle.type != HHImageStyleTypeLine) {
        [self.textView resignFirstResponder];
    }
    
    /**
        5. 写入文件，取得url
     */
    __weak __typeof(&*self)weakSelf = self;
    //filePath.path: /var/mobile/Containers/Data/Application/C0EC5894-19CF-4BB4-8086-811E7B5CD7EE/Documents/1482717862105412.png
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *documentDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                    inDomain:NSUserDomainMask
                                                           appropriateForURL:nil
                                                                      create:NO
                                                                       error:nil];
        NSString *timeSp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        NSString *file = [timeSp stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSURL *filePath = [documentDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", file]];
        
        NSData *imagedata = [weakSelf pressedImageDataWithImage:imageStyle.image];
        if ([imagedata writeToFile:filePath.path atomically:YES]) {
            imageStyle.fileUrl = filePath;
            textAttachment.imageStyle = imageStyle;
        }
    });
}

#pragma mark - 导出为HTML
//html ： 不包含封面和标题 . 作为content传给后台
- (NSString *)exportHTML {
    NSMutableString *content = [LMTextHTMLParser htmlDraftFromAttributedString:self.textView.attributedText];
    [content insertString:@"<style>body{margin:0;padding:0;}</style>" atIndex:0];
    [self attributeStringFromHtmlString:content];
    return content;
}
//html ： 包含封面和标题 预览
- (NSString *)exportHTMLWithTitleAndCoverImage {
    
    NSString *cover = [NSString stringWithFormat:@"<img style=\"margin:0px\" src=\"%@\" width=\"100%%\"/>",_coverImageStyle.fileUrl];
    NSString *title = [NSString stringWithFormat:@"<p style=\"text-align:left;margin:14px 16px 14px 16px;font-size:18px \"><b>%@</b></p>", self.textView.titleTextField.text];
    NSMutableString *content = [LMTextHTMLParser htmlDraftFromAttributedString:self.textView.attributedText];
    [content insertString:@"<style>body{margin:0;padding:0;}</style>" atIndex:0];
    [self attributeStringFromHtmlString:content];
    
    return [[cover stringByAppendingString:title] stringByAppendingString:content];
}
//html ： 保存草稿。目前没用html来保存
- (NSString *)exportSavedHtml {
    
    NSString *content = [LMTextHTMLParser htmlDraftFromAttributedString:self.textView.attributedText];
    
    [self attributeStringFromHtmlString:content];
    
    return content;
}
- (NSAttributedString *)attributeStringFromHtmlString:(NSString *)htmlString {
    
    return [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
}
#pragma mark - 更新文本样式
#pragma mark -- 更新光标段落样式
- (void)updateParagraphTypingAttributes {
    NSMutableDictionary *typingAttributes = [self.textView.typingAttributes mutableCopy];
    typingAttributes[NSFontAttributeName] = self.currentTextStyle.font;
    typingAttributes[NSForegroundColorAttributeName] = self.currentTextStyle.textColor;
    typingAttributes[NSParagraphStyleAttributeName] = self.currentTextStyle.paragraphStyle;
    self.textView.typingAttributes = typingAttributes;
}
#pragma mark -- 更新光标文本样式
- (void)updateTextStyleAttributes {
    NSMutableDictionary *typingAttributes = [self.textView.typingAttributes mutableCopy];
    typingAttributes[NSFontAttributeName] = self.currentTextStyle.font;
    typingAttributes[NSForegroundColorAttributeName] = self.currentTextStyle.textColor;
    self.textView.typingAttributes = typingAttributes;
}
#pragma mark -- 更新选中段落的样式
- (void)updateParagraphStyleForSelection {
    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
    
    NSRange selectedRange = self.textView.selectedRange;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    
    for (NSValue *rangeValue in ranges) {
        NSRange range = rangeValue.rangeValue;
        [attributedText addAttributes:self.textView.typingAttributes range:range];
    }
    
    self.textView.attributedText = attributedText;
    //只要重设textView.attributedText 就会滚动到最底下。所以有重新设置下可视区域
    [self.textView scrollRangeToVisible:selectedRange];
    self.textView.selectedRange = selectedRange;
    
    //或者这样写
//    for (NSValue *rangeValue in ranges) {
//        NSRange range = rangeValue.rangeValue;
//        [self.textView.textStorage addAttribute:NSParagraphStyleAttributeName value:self.currentTextStyle.paragraphStyle range:range];
//    }
}
#pragma mark -- 更新选中文本的样式
- (void)updateTextStyleForSelection {
    if (self.textView.selectedRange.length > 0) {
        [self.textView.textStorage addAttributes:self.textView.typingAttributes range:self.textView.selectedRange];
    }
}

#pragma mark -- 获取光标处的段落样式
- (LMTextStyle *)textStyleForSelection {
    
    LMTextStyle *textStyle = [[LMTextStyle alloc] init];
    UIFont *font = self.textView.typingAttributes[NSFontAttributeName];
    textStyle.bold = font.bold;
    textStyle.italic = font.italic;
    textStyle.fontSize = font.fontSize;
    textStyle.textColor = self.textView.typingAttributes[NSForegroundColorAttributeName];
    textStyle.paragraphStyle = self.textView.typingAttributes[NSParagraphStyleAttributeName];
    return textStyle;
}
#pragma mark -- 刷新：选择文本样式界面
- (void)reloadTextStyleView {
    
    self.textStyleViewController.textStyle = self.currentTextStyle;
    [self.textStyleViewController reload];
}

#pragma mark -- 获取所有选中的段落
/** 
 @"\n几util\n空军建军节\n\n考虑咯啦咯啦空军建军节\n"
 
 -- @"",@"几util",@"空军建军节",@"",@"考虑咯啦咯啦空军建军节",@""
 NSRange: {0, 1},
 NSRange: {1, 6},
 NSRange: {7, 6},
 NSRange: {13, 1},
 NSRange: {14, 12}
 */
- (NSArray *)rangesOfParagraphForCurrentSelection {
    NSRange selection = self.textView.selectedRange;
    NSInteger location;
    NSInteger length;
    
    NSInteger start = 0;
    NSInteger end = selection.location;
    NSRange range = [self.textView.text rangeOfString:@"\n"
                                              options:NSBackwardsSearch
                                                range:NSMakeRange(start, end - start)];
    location = (range.location != NSNotFound) ? range.location + 1 : 0;
    
    start = selection.location + selection.length;
    end = self.textView.text.length;
    range = [self.textView.text rangeOfString:@"\n"
                                      options:0
                                        range:NSMakeRange(start, end - start)];
    length = (range.location != NSNotFound) ? (range.location - location) : (self.textView.text.length - location);
    
    range = NSMakeRange(location, length);
    NSString *textInRange = [self.textView.text substringWithRange:range];
    NSArray *components = [textInRange componentsSeparatedByString:@"\n"];
    
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if (i == components.count - 1) {
            if (component.length == 0) {
                break;
            }
            else {
                [ranges addObject:[NSValue valueWithRange:NSMakeRange(location, component.length)]];
            }
        }
        else {
            [ranges addObject:[NSValue valueWithRange:NSMakeRange(location, component.length + 1)]];
            location += component.length + 1;
        }
    }
    if (ranges.count == 0) {
        return nil;
    }
    return ranges;
}
#pragma mark -- 重设图片的bounds ,无效，没有用
- (void)resetAttachmentBounds {
    NSRange effectiveRange = NSMakeRange(0, 0);
    while (effectiveRange.location + effectiveRange.length < self.textView.attributedText.length) {
        
        NSDictionary *attributes = [self.textView.attributedText attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        HHTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            NSLog(@"%@",NSStringFromRange(effectiveRange));
            NSLog(@"%@",NSStringFromCGRect(attachment.bounds));
            attachment.bounds = CGRectMake(0, 0, kScreenWidth, attachment.image.size.height / attachment.image.size.width * kScreenWidth);
        }
        else {
            
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
}
#pragma mark - 打印有效range
- (void)logEffectiveRange {
    NSRange effectiveRange = NSMakeRange(0, 0);
    while (effectiveRange.location + effectiveRange.length < self.textView.attributedText.length) {
        
        [self.textView.attributedText attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        
        NSLog(@"effectiveRange : %@",NSStringFromRange(effectiveRange));
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
}
#pragma mark - 网络请求专题内容
#pragma mark -- 获取专题内容
/** http://b82.ssrj.com/api/v5/index/infromcategorylist?appVersion=2.2.0
 "data":[
 {
 "id":0,
 "name":"全部专题",
 "uncheckedImage":"http://www.ssrj.com/upload/image/201611/44475d90-4130-4fe2-b472-d254d9de33c7.png",
 "checkedImage":"http://www.ssrj.com/upload/image/201611/c50d5656-aa3b-4915-8ac5-a666baf47585.png"
 },
 */
- (void)getCategoryData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = CategoryUrl;
    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HTUIHelper shareInstance] removeHUD];
        if ([responseObject[@"stata"] boolValue] == 0) {
            [weakSelf.specialTopicModelArr removeAllObjects];
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *err;
                RJTopicCategoryModel *model = [[RJTopicCategoryModel alloc] initWithDictionary:dict error:&err];
                if (!err) {
                    //剔除全部标题
                    if ([model.id intValue] == 0) {
                        continue;
                    }
                    [weakSelf.specialTopicModelArr addObject:model];
                }
            }
        }else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance] removeHUD];
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
    }];
}
#pragma mark -- 上传资讯
/** http://192.168.1.173:9999/api/v1/information/upload_information?token=daf1a91acee1be236510cc2bd1873b49
 //参数
 {
 "collocation_ids" =     (
 );
 content = "<p style=\"text-indent:0em;text-align:left;margin:4px auto 0px auto;\"><font style=\"font-size:25.000000px;color:#000000\"><b>\U521a\U521a\U516c\U5e03</b></font></p>";
 "goods_ids" =     (
 );
 "inform_category" = 0;
 title = vvv;
 图片..
 }
 */
- (void)pubLishInformation {
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:nil];
        return;
    }
    //后台要求我get必须传token
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSString *token = [RJAccountManager sharedInstance].token;
    requestInfo.URLString = [NSString stringWithFormat:@"%@?token=%@",PublishInformationUrl,token];
    requestInfo.fileBodyParams = [self getImageDict];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_textView.titleTextField.text forKey:@"title"];
    [dict setObject:[self exportHTML] forKey:@"content"];
    [dict setObject:[self getMatchIds] forKey:@"collocation_ids"];
    [dict setObject:[self getGoodsIds] forKey:@"goods_ids"];
    [dict setObject:[_selectSpacialTopicModel.id stringValue] forKey:@"inform_category"];
    
    NSLog(@"%@",dict);
    
    requestInfo.postParams = dict;
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]uploadWithRequestInfo:requestInfo uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HTUIHelper shareInstance] removeHUD];
        if ([responseObject[@"state"] intValue] == 0) {
            [self deleteDraft];
            [HTUIHelper addHUDToView:self.view withString:@"发布成功" hideDelay:1];
            SMPublishFinishedController *finish = [[SMPublishFinishedController alloc] init];
            finish.publishType = HHPublishTyleInformation;
            finish.informationId = responseObject[@"data"][@"informId"];
            NSError *error;
            finish.shareModel = [[RJHomeTopicShareModel alloc] initWithDictionary:responseObject[@"data"][@"inform"] error:&error];
            [self.navigationController pushViewController:finish animated:YES];
            
        }else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance] removeHUD];
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];

    }];

}
- (RJHomeTopicShareModel *)getTestShareModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"标题" forKey:@"title"];
    [dict setObject:@"我是描述" forKey:@"memo"];
    [dict setObject:@"http://www.ssrj.com/upload/image/201612/5416ca64-0c57-466b-a8c7-905e95d79e5a.jpg" forKey:@"img"];
    [dict setObject:@"http://www.ssrj.com/mobile/inform/content/201612/218/1_app.html" forKey:@"showUrl"];
    [dict setObject:@"http://www.ssrj.com/mobile/inform/content/201612/218/1.html" forKey:@"shareUrl"];
    
    return [[RJHomeTopicShareModel alloc] initWithDictionary:[dict copy] error:nil];
}
- (NSArray *)getGoodsIds {
    NSMutableArray *goods_ids = [NSMutableArray array];
    NSRange effectiveRange = NSMakeRange(0, 0);
    while (effectiveRange.location + effectiveRange.length < self.textView.attributedText.length) {
        
        NSDictionary *attributes = [self.textView.attributedText attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSLog(@"%@",NSStringFromRange(effectiveRange));
        HHTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.imageStyle.type == HHImageStyleTypeGoods) {
                [goods_ids addObject:@(attachment.imageStyle.ID)];
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    return [goods_ids copy];

}
- (NSArray *)getMatchIds {
    NSMutableArray *match_ids = [NSMutableArray array];
    NSRange effectiveRange = NSMakeRange(0, 0);
    while (effectiveRange.location + effectiveRange.length < self.textView.attributedText.length) {
        
        NSDictionary *attributes = [self.textView.attributedText attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSLog(@"%@",NSStringFromRange(effectiveRange));
        HHTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.imageStyle.type == HHImageStyleTypeMatch) {
                [match_ids addObject:@(attachment.imageStyle.ID)];
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    return [match_ids copy];
    
}
- (NSMutableDictionary *)getImageDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //封面图
    ZHALAsset *asset = [[ZHALAsset alloc]init];
    asset.image  = _coverImageStyle.image;
    asset.name =  @"banner_image";
    NSData *imagedata = [self pressedImageDataWithImage:asset.image];

    asset.imageData = imagedata;
    
    [dict setObject:asset forKey:[NSString stringWithFormat:@"banner_image"]];
    
    
    NSRange effectiveRange = NSMakeRange(0, 0);
    int i = 1;
    while (effectiveRange.location + effectiveRange.length < self.textView.attributedText.length) {
        
        NSDictionary *attributes = [self.textView.attributedText attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSLog(@"%@",NSStringFromRange(effectiveRange));
        HHTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.imageStyle.type == HHImageStyleTypeLine || attachment.imageStyle.type == HHImageStyleTypeLibrary) {
                
                ZHALAsset *asset = [[ZHALAsset alloc]init];
                asset.image  = attachment.imageStyle.image;
                NSData *imagedata = [self pressedImageDataWithImage:asset.image];
                asset.imageData = imagedata;
                asset.name = [NSString stringWithFormat:@"image_%d",i];
                [dict setObject:asset forKey:[NSString stringWithFormat:@"image_%d",i]];
                i++;
                
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    
    NSLog(@"image === %@",dict);
    
    return dict;
}
#pragma mark - event
#pragma mark -- 点击键盘工具条
- (void)inputAccessoryViewIndexDidChanged:(HMSegmentedControl *)inputAccessoryView {
    NSInteger index = inputAccessoryView.selectedSegmentIndex;
    CGRect rect = self.view.bounds;
    rect.size.height = self.keyboardSpacingHeight - CGRectGetHeight(self.contentInputAccessoryView.frame);
    
    //添加图片
    if (index == 1) {
        [self.textView.titleTextField resignFirstResponder];
        [self.textView resignFirstResponder];
        AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.showEmptyGroups = YES;
        picker.minimumNumberOfSelection = 1;
        picker.maximumNumberOfSelection = 9;
        picker.multipleSelection = NO;
        picker.shouldClip = YES;
        picker.delegate = self;
        picker.cropMode = RSKImageCropModeSquare;
        [self.contentInputAccessoryView setSelectedSegmentIndex:0 animated:NO];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
        [nav setNavigationBarHidden:YES];
        [self presentViewController:nav animated:YES completion:nil];
    }
    //文字格式
    else if (index == 2) {
        UIView *inputView = [[UIView alloc] initWithFrame:rect];
        self.textStyleViewController.view.frame = rect;
        [inputView addSubview:self.textStyleViewController.view];
        self.textView.inputView = inputView;
    }
    //添加单品或者搭配
    else if (index == 3) {
        [self.textView.titleTextField resignFirstResponder];
        [self.textView resignFirstResponder];
        HHSelecteGoodsOrMatchController *select = [[HHSelecteGoodsOrMatchController alloc] init];
        [self.navigationController pushViewController:select animated:YES];
        [self.contentInputAccessoryView setSelectedSegmentIndex:0 animated:NO];
        self.textView.inputView = nil;
    }
    //添加 线
    else if (index == 4) {
        UIView *inputView = [[UIView alloc] initWithFrame:rect];
        self.lineStyleViewController.view.frame = rect;
        [inputView addSubview:self.lineStyleViewController.view];
        self.textView.inputView = inputView;
    }
    //回到原键盘
    else {
        self.textView.inputView = nil;
    }
    //刷新键盘
    [self.textView reloadInputViews];
}
#pragma mark -- 点击专题按钮
- (void)clickSelectSpecialTopicBtn:(UIButton *)button {
    if (self.textView.titleTextField.isFirstResponder) {
        _isShouldBegin = NO;
        [self.textView.titleTextField resignFirstResponder];
    }
    [self.textView resignFirstResponder];
    
    if (self.specialTopicModelArr.count == 0) {
        [self getCategoryData];
        return;
    }
    if (!_alertView) {
        _alertView = [[HHSpecialTopicAlertView alloc] init];
        _alertView.delegate = self;
    }
    NSInteger index = 10000;
    if (_selectSpacialTopicModel) {
        for (RJTopicCategoryModel *model in _specialTopicModelArr) {
            if ([model.id integerValue] == [_selectSpacialTopicModel.id integerValue]) {
                index = [_specialTopicModelArr indexOfObject:model];
            }
        }
    }
    
    [_alertView showWithRect:[self.textView convertRect:button.frame toView:[UIApplication sharedApplication].keyWindow] modelArray:self.specialTopicModelArr selectBtnIndex:index];
    _alertView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _textView.selectSpecialTopicBtn.hidden = YES;
        _alertView.hidden = NO;
    }];
}
#pragma mark -- 点击菜单
- (void)menuBtnClick {
    if (self.textView.titleTextField.isFirstResponder) {
        _isShouldBegin = NO;
        [self.textView.titleTextField resignFirstResponder];
    }
    [self.textView resignFirstResponder];
    
    [self.contentInputAccessoryView setSelectedSegmentIndex:0 animated:NO];
    self.textView.inputView = nil;
#pragma mark -- 预览
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *preview = [UIAlertAction actionWithTitle:@"预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self checkContentStandard]) {
            
            HHHTMLViewController *htmlVc = [[HHHTMLViewController alloc] init];
            htmlVc.HTMLString = [self exportHTMLWithTitleAndCoverImage];
            [self.navigationController pushViewController:htmlVc animated:YES];
        }
    }];
#pragma mark -- 保存
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        if (![self checkContentStandard]) {
//            return;
//        }
        
        [self saveRichTextToFile];
        
    }];
#pragma mark -- 打开草稿
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"打开我的草稿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        HHInforDraftController *draft = [[HHInforDraftController alloc] init];
        draft.delegate = self;
        [self.navigationController pushViewController:draft animated:YES];
    }];
#pragma mark -- 发布资讯
    UIAlertAction *publish = [UIAlertAction actionWithTitle:@"发布资讯" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self checkContentStandard]) {
            [self pubLishInformation];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertview addAction:preview];
    [alertview addAction:save];
    [alertview addAction:open];
    [alertview addAction:publish];
    [alertview addAction:cancel];
    [self.navigationController presentViewController:alertview animated:YES completion:nil];
}
//校验输入内容是否符合要求
- (BOOL)checkContentStandard {
    if (!_hasAddCoverImage) {
        [HTUIHelper addHUDToWindowWithString:@"请添加封面图" hideDelay:1];
        return NO;
    }
    if (!_hasSelectSpecialTopic) {
        [HTUIHelper addHUDToWindowWithString:@"请选择专题" hideDelay:1];
        return NO;
    }
    if ([_textView.titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [HTUIHelper addHUDToWindowWithString:@"请输入标题" hideDelay:1];
        return NO;
    }
    return YES;
}

#pragma mark -- <HHInformationTextViewDelegate>  点击添加封面
- (void)informationTextView:(HHInformationTextView *)informationTextView didClickCover:(UIImageView *)coverImageView {
    if (self.textView.titleTextField.isFirstResponder) {
        _isShouldBegin = NO;
        [self.textView.titleTextField resignFirstResponder];
    }
    [self.textView resignFirstResponder];
    AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = YES;
    picker.minimumNumberOfSelection = 1;
    picker.maximumNumberOfSelection = 9;
    picker.multipleSelection = NO;
    picker.shouldClip = YES;
    picker.delegate = self;
    picker.cropMode = RSKImageCropModeCustom;
    [self.contentInputAccessoryView setSelectedSegmentIndex:0 animated:NO];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)back:(id)sender {
    
    [self.textView.titleTextField resignFirstResponder];
    [self.textView resignFirstResponder];
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:@"提示" message:@"是否放弃当前操作？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertview addAction:save];
    [alertview addAction:cancel];
    [self.navigationController presentViewController:alertview animated:YES completion:nil];
}
#pragma mark - 删除草稿
- (void)deleteDraft {
    
    NSArray *draftModels = [self getRichTextModels];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:draftModels];
    for (HHInforDraftModel *model in draftModels) {
        if ([_currentDraftModel.ID isEqualToString:model.ID]) {
            [mutableArr removeObject:model];
        }
    }
    NSString *file = [self getInformationDraftFilePath];
    [NSKeyedArchiver archiveRootObject:mutableArr toFile:file];
    
}
#pragma mark - 保存草稿

- (void)saveRichTextToFile {
    //创建文件夹
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"information_draft"];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL isDirExist = [manager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!isDirExist) {
        NSError *err;
        if ([manager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&err] == YES) {
        }else {
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        }
    }else {
        
        NSString *file = [filePath stringByAppendingPathComponent:@"richText.txt"];
        
        NSArray *arr = [self getRichTextModels];
        NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:arr];
        if (_currentDraftModel) {
            _currentDraftModel.coverImageStyle = _coverImageStyle;
            _currentDraftModel.title = _textView.titleTextField.text;
            _currentDraftModel.specialTopicId = [_selectSpacialTopicModel.id stringValue];
            _currentDraftModel.specialTopicName = _selectSpacialTopicModel.name;
            _currentDraftModel.attributeString = self.textView.attributedText;
            BOOL hasExistCurrentModel = NO;
            for (HHInforDraftModel *model in arr) {
                if ([model.ID isEqualToString:_currentDraftModel.ID]) {
                    [mutableArr replaceObjectAtIndex:[arr indexOfObject:model] withObject:_currentDraftModel];
                    hasExistCurrentModel = YES;
                }
            }
            if (hasExistCurrentModel == NO) {
                [mutableArr insertObject:_currentDraftModel atIndex:0];
            }
            BOOL isSaved = [NSKeyedArchiver archiveRootObject:mutableArr toFile:file];
            if (isSaved) {
                [HTUIHelper addHUDToView:self.view withString:@"修改成功" hideDelay:1];
            }else {
                [HTUIHelper addHUDToView:self.view withString:@"修改失败" hideDelay:1];
            }
        }else {
            
            NSString *timeSp = [NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]];
            HHInforDraftModel *model = [[HHInforDraftModel alloc] init];
            model.coverImageStyle = _coverImageStyle;
            model.ID = timeSp;
            model.title = _textView.titleTextField.text;
            model.specialTopicId = [_selectSpacialTopicModel.id stringValue];
            model.specialTopicName = _selectSpacialTopicModel.name;
            model.attributeString = self.textView.attributedText;
            
            [mutableArr insertObject:model atIndex:0];
            BOOL isSaved = [NSKeyedArchiver archiveRootObject:mutableArr toFile:file];
            if (isSaved) {
                [HTUIHelper addHUDToView:self.view withString:@"保存成功" hideDelay:1];
                _currentDraftModel = model;
            }else {
                [HTUIHelper addHUDToView:self.view withString:@"保存失败" hideDelay:1];
            }
        }
    }
}
#pragma mark -- 获取草稿数组
- (NSArray *)getRichTextModels {
    NSString *file = [self getInformationDraftFilePath];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    
    if (array && array.count) {
        
        return array;
    }
    return nil;
}
#pragma mark -- 获取草稿存储文件地址
- (NSString *)getInformationDraftFilePath {
    //创建文件夹
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"information_draft"];
    NSString *file = [filePath stringByAppendingPathComponent:@"richText.txt"];
    return file;
}
#pragma mark - delegate
#pragma mark -- <HHInforDraftControllerDelegate> 打开草稿回调
- (void)didSelectDraftWithModel:(HHInforDraftModel *)model {
    /** 
        1.切换 记录与当前编辑内容相关 的属性
     */
    self.currentDraftModel = model;
    self.coverImageStyle = model.coverImageStyle;
    
    _selectSpacialTopicModel = [[RJTopicCategoryModel alloc] init];
    if (model.specialTopicId == nil) {
        _selectSpacialTopicModel = nil;
        self.hasSelectSpecialTopic = NO;
    }else {
        self.selectSpacialTopicModel.id = [NSNumber numberWithInt:model.specialTopicId.intValue];
        self.selectSpacialTopicModel.name = model.specialTopicName;
        self.hasSelectSpecialTopic = YES;
    }
    
    //当前的样式改成正文。
    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
    
    /**
        2.切换 编辑内容 封面 标题 和专题
     */
    if (model.coverImageStyle.image) {
        self.textView.coverImageView.image = model.coverImageStyle.image;
        self.hasAddCoverImage = YES;
    }else {
        self.textView.coverImageView.image = [UIImage imageNamed:@"640X360"];
        self.hasAddCoverImage = NO;
    }
    self.textView.attributedText = model.attributeString;
    self.textView.titleTextField.text = model.title;
    if (_selectSpacialTopicModel) {
        [self.textView.selectSpecialTopicBtn selectedSpecialTopic:_selectSpacialTopicModel.name];
    }else {
        [self.textView.selectSpecialTopicBtn selectedNone];
    }
}
#pragma mark -- <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.textView resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    _isShouldBegin = YES;
}
#pragma mark -- <UITextViewDelegate>
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"textViewShouldBeginEditing");
    _textView.inputAccessoryView = self.contentInputAccessoryView;
    
    /**
     当textField 处在第一响应时，点击专题，textView会自动成为第一响应者，所以内容会滚动到最后。在这里限制textView成为第一响应者。
     */
    if (!_isShouldBegin && self.textView.titleTextField.isFirstResponder) {
        return NO;
    }else {
        return YES;
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    NSLog(@"textViewDidBeginEditing");
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _textView.inputAccessoryView = nil;
    return YES;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    _textView.selectedRange = NSMakeRange(0, 0);
    if (self.textView.titleTextField.isFirstResponder) {
        _isShouldBegin = NO;
        [self.textView.titleTextField resignFirstResponder];
    }
    [self.textView resignFirstResponder];
}
#pragma mark --- 输入或删除内容
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    //不让输入笑脸
    if ([text isEqualToString:@"☻"]) {
        return NO;
    }
    /**
     1.图片后面禁止输入内容（除了换行和删除操作）
     */
    if ([self checkIsImage] && ![text isEqualToString:@"\n"] && ![text isEqualToString:@""]) {
        
//        NSRange selectRange = self.textView.selectedRange;
//        LMTextStyle *textStyle = [LMTextStyle textStyleWithType:LMTextStyleFormatNormal];
//        NSDictionary *dict = @{NSFontAttributeName : textStyle.font, NSParagraphStyleAttributeName : textStyle.paragraphStyle, NSForegroundColorAttributeName : textStyle.textColor};
//        NSMutableAttributedString *newLine = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",text] attributes:dict];
//        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
//        [attributeText insertAttributedString:newLine atIndex:selectRange.location];
//        self.textView.attributedText = attributeText;
//        
//        /** 设置可视位置和光标位置 */
//        self.textView.selectedRange = NSMakeRange(selectRange.location + newLine.length, 0);
//        [self.textView scrollRangeToVisible:NSMakeRange(selectRange.location + newLine.length, 0)];
        return NO;
    }
    /**
     2.禁止图片前面输入内容或删除内容
     */
    if ([self checkAfterIsImage] && ![text isEqualToString:@"\n"]) {
        return NO;
    }
    
    //根据操作： 控制无序列表状态样式的改变
    /**
    3.不让跨段操作，因为跨段样式修改，会有问题。
     */
    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
    if (ranges.count > 1) {
        return NO;
    }
    
    if (self.currentTextStyle.type == LMTextStyleFormatList) {
        
        
        //光标在该段的第0个位置
        NSRange currentParagraphRange = [ranges.lastObject rangeValue];
        if (currentParagraphRange.location == textView.selectedRange.location) {
            return NO;
        }
        /**
            4.点击换行，段首插入listString
         */
        if ([text isEqualToString:@"\n"]) {
            NSRange selectRange = self.textView.selectedRange;
            LMTextStyle *textStyle = [LMTextStyle textStyleWithType:LMTextStyleFormatNormal];
            NSDictionary *dict = @{NSFontAttributeName : textStyle.font, NSParagraphStyleAttributeName : textStyle.paragraphStyle, NSForegroundColorAttributeName : textStyle.textColor};
            NSMutableAttributedString *newLine = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:dict];
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",ListString] attributes:self.textView.typingAttributes];
            [attribute insertAttributedString:newLine atIndex:0];
            
            NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
            [attributeText insertAttributedString:attribute atIndex:selectRange.location];
            self.textView.attributedText = attributeText;
            
            /** 设置可视位置和光标位置 */
            self.textView.selectedRange = NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - selectRange.length + attribute.length, 0);
            [self.textView scrollRangeToVisible:NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - selectRange.length + attribute.length, 0)];
            
            return NO;
        }
        /**
         5.控制当前段落 listString 的显示
         */
        if (ranges.count > 0) {
            
            /**
             5.1.判断操作文本位置是否与listString位置有交集
             */
            
            NSRange intersectionRange = NSIntersectionRange(NSMakeRange(currentParagraphRange.location, ListString.length), range);
            BOOL hasIntersection = !NSEqualRanges(intersectionRange, NSMakeRange(0, 0));
            
            
            if (hasIntersection) {
                
                /**
                 5.2 操作了listString。需要删除listString
                 */
                
                //1. 如果不是第一段 需要删除 \n 和listString
                if (currentParagraphRange.location > 0) {
                    NSAttributedString *subString = [textView.textStorage attributedSubstringFromRange:NSMakeRange(currentParagraphRange.location - 1, 1)];
                    if ([subString.string isEqualToString:@"\n"]) {
                        
                        [textView.textStorage deleteCharactersInRange:NSMakeRange(currentParagraphRange.location - 1, ListString.length + 1)];
                        
                        textView.selectedRange = NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length - 1, 0);
                        [textView scrollRangeToVisible:NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length - 1, 0)];
                    }else {
                        [textView.textStorage deleteCharactersInRange:NSMakeRange(currentParagraphRange.location, ListString.length)];
                        textView.selectedRange = NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length, 0);
                        [textView scrollRangeToVisible:NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length, 0)];
                    }
                }
                //2. 如果是第一段 需要删除 listString
                else {
                    
                    //改成正文格式
                    self.currentTextStyle = [LMTextStyle textStyleWithType:LMTextStyleFormatNormal];
                    [self updateParagraphTypingAttributes];
                    [self updateParagraphStyleForSelection];
                    
                    [textView.textStorage deleteCharactersInRange:NSMakeRange(currentParagraphRange.location, ListString.length)];
                    textView.selectedRange = NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length, 0);
                    [textView scrollRangeToVisible:NSMakeRange(currentParagraphRange.location + currentParagraphRange.length - ListString.length, 0)];
                }
                return NO;
                
            }
        }
    }
    return YES;
}
#pragma mark --- 焦点改变 
//（输入内容后调用 ， 改变光标位置调用）
- (void)textViewDidChangeSelection:(UITextView *)textView {
    // 只要有内容, 就隐藏占位文字label
    _textView.placeholderLabel.hidden = _textView.attributedText.length > 0 ? YES : NO;

    //更换到当前位置的富文本样式
    self.currentTextStyle = [self textStyleForSelection];
    //刷新选择文本样式界面,匹配当前文本样式
    [self reloadTextStyleView];
    
    //    [self logEffectiveRange
    //调用这个函数，能够正常滚动了：1.无序列表，2.线。
    [self layoutTextView];
}
#pragma mark -- <AJPhotoPickerProtocol> 选择照片后的回调
- (void)photoPicker:(AJPhotoPickerViewController *)picker didClipImageDone:(UIImage *)image {
    if (picker.cropMode == RSKImageCropModeCustom) {
        _hasAddCoverImage = YES;
        self.textView.coverImageView.image = image;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // 实际应用时候可以将存本地的操作改为上传到服务器，URL 也由本地路径改为服务器图片地址。
            NSURL *documentDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                        inDomain:NSUserDomainMask
                                                               appropriateForURL:nil
                                                                          create:NO
                                                                           error:nil];
            NSURL *filePath = [documentDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [NSDate date].description]];
            NSData *originImageData = UIImagePNGRepresentation(image);
            
            if ([originImageData writeToFile:filePath.path atomically:YES]) {
                _coverImageStyle = [[HHImageStyle alloc] init];
                _coverImageStyle.fileUrl = filePath;
                _coverImageStyle.type = HHImageStyleTypeLibrary;
                _coverImageStyle.image = image;
            }
        });
        
    }else {
        HHImageStyle *imageStyle = [HHImageStyle imageStyleWithType:HHImageStyleTypeLibrary];
        imageStyle.image = image;
        [self insertImageWithImageStyle:imageStyle];
    }
}
#pragma mark -- <HHLineStyleViewControllerDelegate> 选择线条
- (void)yf_didSelectLineStyle:(HHImageStyle *)imageStyle {
    
    [self insertImageWithImageStyle:imageStyle];
}
#pragma mark -- <HHTextStyleViewControllerDelegate> 改变文本样式
- (void)yf_didChangedTextStyle:(LMTextStyle *)textStyle {
    
    /**
     0.图片不让修改样式
     */
    
    if ([self checkIsImage]) {
        [self reloadTextStyleView];
        return;
    }
    if ([self checkAfterIsImage]) {
        [self reloadTextStyleView];
        return;
    }
    
    /**
        1.现在选中多个段落，会有问题，控制选中多个段落。不能修改样式
     */
    
    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
    if (ranges.count > 1) {
        [self reloadTextStyleView];
        return;
    }
    
    /**
        2.修改样式
     */
    
    self.currentTextStyle = textStyle;
    [self updateParagraphTypingAttributes];
    [self updateParagraphStyleForSelection];
    
    /**
        3. 控制listString 的显示
     */
    if (textStyle.type == LMTextStyleFormatList) {
        /**
         3.1 选中段落无内容 插入listString
         */
        if (ranges.count == 0) {
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:ListString attributes:self.textView.typingAttributes];
            if (![[self.textView.textStorage attributedSubstringFromRange:self.textView.selectedRange].string containsString:ListString]) {
                
                [self.textView.textStorage insertAttributedString:attribute atIndex:self.textView.selectedRange.location];
                self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + self.textView.selectedRange.length + ListString.length, 0);
            }
            return;
        }
        
        for (NSValue *value in ranges) {
            NSRange selectRange = value.rangeValue;
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:ListString attributes:self.textView.typingAttributes];
            if (![[self.textView.textStorage attributedSubstringFromRange:selectRange].string containsString:ListString]) {
                
                [self.textView.textStorage insertAttributedString:attribute atIndex:selectRange.location];
                self.textView.selectedRange = NSMakeRange(selectRange.location + selectRange.length + ListString.length, 0);
            }
        }
    }else {
        NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
        for (NSValue *value in ranges) {
            NSRange selectRange = value.rangeValue;
            
            if ([[self.textView.textStorage attributedSubstringFromRange:selectRange].string containsString:ListString]) {
                
                self.textView.selectedRange = NSMakeRange(selectRange.location + selectRange.length - ListString.length, 0);
                [self.textView.textStorage deleteCharactersInRange:NSMakeRange(selectRange.location, ListString.length)];
            }
        }
    }
    [self logCurrentTextStyle];
    [self logEffectiveRange];
    [self updateTextStyleAttributes];
    [self updateTextStyleForSelection];
}
// 判断光标前是否是图片
- (BOOL)checkIsImage {
    NSRange range = self.textView.selectedRange;
    if (range.location > 0) {
        NSAttributedString *attributeString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(range.location - 1, 1)];
        NSRange effectiveRange = NSMakeRange(0, 1);
        
        NSTextAttachment *attachment = [attributeString attributesAtIndex:0 effectiveRange:&effectiveRange][NSAttachmentAttributeName];
        if (attachment) {
            return YES;
        }
    }
    
    return NO;
}
// 判断光标后是否是图片
- (BOOL)checkAfterIsImage {
    NSRange range = self.textView.selectedRange;
    
    if (range.location + 1 <= self.textView.attributedText.length) {
        NSAttributedString *attributeString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(range.location, 1)];
        NSRange effectiveRange = NSMakeRange(0, 1);
        
        NSTextAttachment *attachment = [attributeString attributesAtIndex:0 effectiveRange:&effectiveRange][NSAttachmentAttributeName];
        if (attachment) {
            return YES;
        }
    }
    return NO;
}
- (void)logCurrentTextStyle {
    NSLog(@"%zd",self.currentTextStyle.type);
}
#pragma mark -- HHSpecialTopicAlertViewDelegate 选择专题后的回调
- (void)specialTopicAlertView:(HHSpecialTopicAlertView *)alertView clickBtnIndex:(NSInteger)index {
    _textView.selectSpecialTopicBtn.hidden = NO;
    _hasSelectSpecialTopic = YES;
    // 选择完专题后要改变
    RJTopicCategoryModel *model = self.specialTopicModelArr[index];
    [_textView.selectSpecialTopicBtn selectedSpecialTopic:model.name];
    
    _selectSpacialTopicModel = model;
}
- (void)specialTopicAlertViewCanceled {
    _textView.selectSpecialTopicBtn.hidden = NO;
}
#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"keyboardSize.height -- %.f",keyboardSize.height);
    if (self.keyboardSpacingHeight == keyboardSize.height) {
        return;
    }
    self.keyboardSpacingHeight = keyboardSize.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutTextView];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if (self.keyboardSpacingHeight == 0) {
        return;
    }
    self.keyboardSpacingHeight = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutTextView];
    } completion:nil];
}


#pragma mark - get
- (NSMutableArray *)specialTopicModelArr {
    if (!_specialTopicModelArr) {
        _specialTopicModelArr = [NSMutableArray array];
    }
    return _specialTopicModelArr;
}
- (HHLineStyleViewController *)lineStyleViewController {
    if (!_lineStyleViewController) {
        _lineStyleViewController = [[HHLineStyleViewController alloc] init];
        _lineStyleViewController.delegate = self;
    }
    return _lineStyleViewController;
}
- (HHTextStyleViewController *)textStyleViewController {
    if (!_textStyleViewController) {
        _textStyleViewController = [[HHTextStyleViewController alloc] init];
        _textStyleViewController.textStyle = self.currentTextStyle;
        _textStyleViewController.delegate = self;
    }
    return _textStyleViewController;
}
#pragma mark - other
- (void)layoutTextView {
    //设置textView的frame需要这样设置，才会自动滚动
    CGRect rect = self.view.bounds;
//    rect.origin.y = [self.topLayoutGuide length];
//    rect.size.height -= rect.origin.y;
    self.textView.frame = rect;
    
    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom = self.keyboardSpacingHeight;
    self.textView.contentInset = insets;
}

#pragma mark - 压缩图片
- (NSData *)pressedImageDataWithImage:(UIImage *)image {
    NSData *imagedata = UIImageJPEGRepresentation(image, 1);
    
    float qulity = 1;
    NSData *minData = [NSData dataWithData:imagedata];
    while (imagedata.length > 50 * 1024 && qulity >= 0.2) {
        qulity -= 0.1;
        imagedata = UIImageJPEGRepresentation(image, qulity);
        if (imagedata.length < minData.length) {
            minData = imagedata;
        }
    }
    if (imagedata.length > 50 * 1024) {
        imagedata = minData;
    }
    NSLog(@"imagedata.length = %.f /kb",imagedata.length / 1024.0);
    return imagedata;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
