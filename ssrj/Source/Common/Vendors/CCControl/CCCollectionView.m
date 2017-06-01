
#import "CCCollectionView.h"

@interface CCCollectionView ()
@end

@implementation CCCollectionView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self nextResponder]) {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self nextResponder]) {
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self nextResponder]) {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}

@end
