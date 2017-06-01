
#import "CCButton.h"

@interface CCButton ()
@end

@implementation CCButton
- (void)onInit {
    [super onInit];
    [self addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

- (void)afterInit {
    [super afterInit];
    self.agentButton.userInteractionEnabled = NO;
    self.strong_agentButton.userInteractionEnabled = NO;
    self.icon.userInteractionEnabled = NO;
    self.strong_icon.userInteractionEnabled = NO;
}

#pragma mark -
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        if (self.selecteEffectBlock) {
            self.selecteEffectBlock(self);
        }
    }
    else {
        if (self.unselecteEffectBlock) {
            self.unselecteEffectBlock(self);
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.highlightEffectBlock) {
            self.highlightEffectBlock(self);
        }
    }
    else {
        if (self.unhighlightEffectBlock) {
            self.unhighlightEffectBlock(self);
        }
    }
}

- (void)onTouchUpInside {
    if (self.agentButton && !self.agentButton.userInteractionEnabled) {
        [self.agentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    if (self.strong_agentButton && !self.strong_agentButton.userInteractionEnabled) {
        [self.strong_agentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.tappedBlock) {
        self.tappedBlock(self);
    }
#pragma clang diagnostic pop
}

@end
