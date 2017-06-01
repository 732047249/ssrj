//
//  HHInformationViewController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "HHImageStyle.h"
#import "HHInforDraftModel.h"
@interface HHInformationViewController : RJBasicViewController
- (void)insertImageWithImageStyle:(HHImageStyle *)imageStyle;
/** 新建资讯，删除资讯内容 */
- (void)deleteInformation;
@end
