
#import "CCPhotoPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface CCPhotoPickerViewController ()
@property (strong, nonatomic) ALAssetsLibrary * assetsLibrary;
@property (strong, nonatomic) NSMutableArray * albumsArray;
@end

@implementation CCPhotoPickerViewController
- (void)viewDidLoad{
    [super viewDidLoad];
   
        self.assetsLibrary = [[ALAssetsLibrary alloc]init];
        self.albumsArray = [NSMutableArray array];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                //过滤照片
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [self.albumsArray addObject:group];
            }else{
                ALAssetsGroup *group = [self.albumsArray firstObject];
//                NSLog(@"%@",group);
            }
        } failureBlock:^(NSError *error) {
//            NSLog(@"error");
        }];
    
}
- (IBAction)dismissButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
