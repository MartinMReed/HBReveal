/* Copyright (c) 2013-2014 Martin M Reed
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "UIView+HBReveal.h"

#import <objc/runtime.h>

static const NSString *REVEAL_ENTRY;

@interface HBRevealEntry : NSObject
{
    @package
    HBRevealSlide slide; // assign
    UIView *contentView; // retain
    UIView *containerView; // retain
    UIView *coverView; // retain
    CGRect originalFrame; // assign
    void (^hideCallback)(UIView *); // copy
}
@end

@implementation HBRevealEntry

- (void)dealloc
{
    [contentView release];
    [containerView release];
    [coverView release];
    [hideCallback release];
    [super dealloc];
}

@end

@implementation UIView (HBReveal)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
    
    if (revealEntry)
    {
        UIView *contentView = revealEntry->contentView;
        
        CGRect bounds = self.bounds;
        CGRect containerBounds = contentView.bounds;
        bounds.size = CGSizeMake(bounds.size.width + containerBounds.size.width, bounds.size.height);
        
        if (CGRectContainsPoint(bounds, point)) {
            return YES;
        }
    }
    
    return CGRectContainsPoint(self.bounds, point);
}

- (void)panHide:(UIPanGestureRecognizer *)gestureRecognizer
{
    HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
    UIView *coverView = revealEntry->coverView;
    
    CGPoint translation = [gestureRecognizer translationInView:coverView];
    
    if (fabsf(translation.x) > fabsf(translation.y)) {
        [self hide];
    }
}

- (void)hide
{
    HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
    UIView *coverView = revealEntry->coverView;
    
    if (![coverView isUserInteractionEnabled]) return;
    [coverView setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        UIView *containerView = revealEntry->containerView;
        UIView *contentView = revealEntry->contentView;
        
        [containerView sendSubviewToBack:contentView];
        
        self.frame = revealEntry->originalFrame;
        
    } completion:^(BOOL finished){
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        UIView *containerView = revealEntry->containerView;
        UIView *contentView = revealEntry->contentView;
        
        void (^hideCallback)(UIView *) = revealEntry->hideCallback;
        if (hideCallback) {
            hideCallback(contentView);
        }
        
        [containerView.superview addSubview:self];
        [containerView removeFromSuperview];
        
        objc_setAssociatedObject(self, &REVEAL_ENTRY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)reveal:(UIView *)contentView slide:(HBRevealSlide)slide hideCallback:(void (^)(UIView *))hideCallback
{
    if (!contentView) {
        [self hide];
        return;
    }
    
    HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
    
    if (revealEntry)
    {
        UIView *containerView = revealEntry->containerView;
        [containerView.superview addSubview:self];
        [containerView removeFromSuperview];
        
        objc_setAssociatedObject(self, &REVEAL_ENTRY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        revealEntry = nil;
    }
    
    CGRect frame = self.frame;
    
    UIView *coverView = [[UIView alloc] initWithFrame:frame];
    [self addHideGestures:coverView];
    
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    [self.superview addSubview:containerView];
    [containerView addSubview:contentView];
    [containerView addSubview:self];
    [containerView addSubview:coverView];
    
    CGRect contentFrame = contentView.frame;
    contentFrame.origin = frame.origin;
    if (slide == kSlideLeft) {
        contentFrame.origin.x += frame.size.width - contentFrame.size.width;
    }
    contentView.frame = contentFrame;
    
    revealEntry = [[HBRevealEntry alloc] init];
    if (hideCallback) revealEntry->hideCallback = [hideCallback copy];
    revealEntry->contentView = [contentView retain];
    revealEntry->coverView = [coverView retain];
    revealEntry->containerView = containerView;
    revealEntry->originalFrame = frame;
    objc_setAssociatedObject(self, &REVEAL_ENTRY, revealEntry, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [revealEntry release];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        UIView *contentView = revealEntry->contentView;
        CGRect contentFrame = contentView.frame;
        
        CGRect frame = self.frame;
        frame.origin.x += (slide == kSlideRight ? 1 : -1 ) *contentFrame.size.width;
        self.frame = frame;
        
    } completion:^(BOOL finished){
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        UIView *containerView = revealEntry->containerView;
        UIView *contentView = revealEntry->contentView;
        [containerView bringSubviewToFront:contentView];
    }];
}

- (void)addHideGestures:(UIView *)view
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(hide)];
    [view addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(panHide:)];
    [view addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
}

@end
