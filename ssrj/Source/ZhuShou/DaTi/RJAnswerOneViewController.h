//
//  RJAnswerOneViewController.h
//  ssrj
//
//  Created by CC on 16/8/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJZhushouPickerView.h"

@protocol RJAnswersSavaDelegate <NSObject>
@optional
- (void)answerSaveWithDictionary:(NSMutableDictionary *)dic controllerIndex:(NSInteger )index;
- (void)nextButtonClickedWithIndex:(NSInteger)index;

- (void)saveRecommentedSizeInfo;

@end

@interface RJAnswerOneViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *weightLable;

@property (weak, nonatomic) IBOutlet UILabel *heightsLabel;

@property (weak, nonatomic) IBOutlet UILabel *bustLabel;

@property (weak, nonatomic) IBOutlet UILabel *waitsLabel;

@property (weak, nonatomic) IBOutlet UILabel *hiplineLabel;

@property (assign, nonatomic) NSInteger weight;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) NSInteger bust;
@property (assign, nonatomic) NSInteger waits;
@property (assign, nonatomic) NSInteger hipline;

@property (strong, nonatomic) RJZhushouPickerView * weightPicker;
@property (strong, nonatomic) RJZhushouPickerView * heightPicker;
@property (strong, nonatomic) RJZhushouPickerView * bustPicker;
@property (strong, nonatomic) RJZhushouPickerView * waitsPicker;
@property (strong, nonatomic) RJZhushouPickerView * hiplinePicker;


@property (assign, nonatomic) id<RJAnswersSavaDelegate> delegate;
@end




@interface AnswerOneJsonModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> * heights;
@property (strong, nonatomic) NSNumber<Optional> * bust;
@property (strong, nonatomic) NSNumber<Optional> * hipline;
@property (strong, nonatomic) NSNumber<Optional> * waist;
@property (strong, nonatomic) NSNumber<Optional> * weight;

@end

