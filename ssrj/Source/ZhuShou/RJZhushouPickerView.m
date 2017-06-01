
#import "RJZhushouPickerView.h"
#define BackViewHeight 240
#define ToolViewHeight 40
#define PickerViewHeight 200
@interface RJZhushouPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) UIView * toolView;
@property (strong, nonatomic) UIButton * saveButton;
@property (strong, nonatomic) UIView * backView;
@property (assign, nonatomic) NSNumber * selectNum;
@property (strong, nonatomic) UIButton * clearButton;
@end

@implementation RJZhushouPickerView


- (instancetype)initWithDataArray:(NSMutableArray *)dataArray unitStr:(NSString *)unitStr defaultRow:(NSInteger)defaultRow{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BackViewHeight, SCREEN_WIDTH, BackViewHeight)];
        
        self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ToolViewHeight, SCREEN_WIDTH, PickerViewHeight)];
        self.backgroundColor = [UIColor colorWithRed:10/255.0f
                                               green:10 / 255.0f
                                                blue:10 / 255.0f
                                               alpha:.6];
        self.toolView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ToolViewHeight)];
        self.toolView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
        self.saveButton = [UIButton buttonWithType:0];
        
        [self.saveButton setTitle:@"完成" forState:0];
        [self.saveButton setTitleColor:[UIColor blackColor] forState:0];
        self.saveButton.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 40, 40);
        
        [self.toolView addSubview:self.saveButton];
        
        self.clearButton = [UIButton buttonWithType:0];
        
        [self.clearButton setTitle:@"我不清楚" forState:0];
        [self.clearButton setTitleColor:[UIColor blackColor] forState:0];
        self.clearButton.frame = CGRectMake(10, 0, 40, 40);
        self.clearButton.titleLabel.font = GetFont(15);
        [self.clearButton sizeToFit];
        self.clearButton.frame = CGRectMake(10, 0, self.clearButton.width, 40);
        [self.toolView addSubview:self.clearButton];
        [self.clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview: self.toolView];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.backgroundColor = [UIColor whiteColor];
        [self.backView addSubview:self.pickerView];
        [self addSubview:_backView];
        self.dataArray = [NSMutableArray arrayWithArray:dataArray];
        self.unitStr = unitStr;
        self.defaultRow = defaultRow;
        [self.pickerView selectRow:self.defaultRow inComponent:0 animated:NO];
        self.selectNum = self.dataArray[self.defaultRow];
        
    }
    return self;
}
- (void)clearButtonAction:(UIButton *)sender{
    if (self.delegate) {
        [self.delegate clearDataUnitStr:self.unitStr pickerView:self];
        [self hidePickerView];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y>=SCREEN_HEIGHT-BackViewHeight) {
        return;
    }
    [self hidePickerView];
}
- (void)showPickerView{
    
    [[AppDelegate shareInstance].window addSubview:self];
    self.backView.origin = CGPointMake(0, SCREEN_HEIGHT);
    [UIView animateWithDuration:.2 animations:^{
        self.backView.origin = CGPointMake(0, SCREEN_HEIGHT - BackViewHeight);
    }];
}
- (void)hidePickerView{
    [UIView animateWithDuration:.2 animations:^{
        self.backView.origin = CGPointMake(0, SCREEN_HEIGHT);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}
- (void)saveButtonAction:(UIButton *)sender{
    if (self.delegate) {
        [self.delegate didSelectDataWithInteger:self.selectNum.intValue unitStr:self.unitStr pickerView:self];
        [self hidePickerView];
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return self.dataArray.count;
    }
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        self.selectNum = self.dataArray[row];
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component ==0) {
        NSNumber *number = self.dataArray[row];
        return [NSString stringWithFormat:@"%d",number.intValue];
    }
    return self.unitStr;

}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        pickerLabel.font = GetFont(15);
        pickerLabel.numberOfLines = 1;
        //        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component

{
    
    return SCREEN_WIDTH/3;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 40;
}
@end
