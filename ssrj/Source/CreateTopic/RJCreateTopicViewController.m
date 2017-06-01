
#import "RJCreateTopicViewController.h"
#import "AJPhotoPickerViewController.h"

@interface RJCreateTopicViewController ()<AJPhotoPickerProtocol>
@property (strong, nonatomic) UIImageView * coverImageView;
@end

@implementation RJCreateTopicViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBarButtonItem:RJNavDoneButtonItem onSide:RJNavRightSide];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *addButton = [UIButton buttonWithType:0];
    [addButton setTitle:@"添加图片" forState:0];
    [addButton sizeToFit];
    [addButton setTitleColor:[UIColor blueColor] forState:0];
    addButton.origin = CGPointMake(50, 50);
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/16 *9)];
    
    self.coverImageView.backgroundColor = [UIColor lightGrayColor];
    
    self.coverImageView.origin = CGPointMake(0, 100);
    [self.view addSubview:_coverImageView];
    
}
- (void)addButtonAction:(id)sender{
    
    AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc]init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = YES;
    picker.delegate = self;
    picker.minimumNumberOfSelection = 1;
    picker.shouldClip = YES;
    picker.cropMode = RSKImageCropModeCustom;
    picker.multipleSelection = NO;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return YES;
    }];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)done:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)photoPickerDidClipImageDone:(UIImage *)image{
    if (image) {
        self.coverImageView.image = image;
    }
}
@end
