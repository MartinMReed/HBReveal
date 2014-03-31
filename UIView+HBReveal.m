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
    HBRevealSlide slide;
    UIView *contentView;
    UIView *coverView;
    NSValue *originalFrame;
    void (^hideCallback)(UIView *);
}
@end

@implementation HBRevealEntry

- (void)dealloc
{
    [contentView release];
    [coverView release];
    [originalFrame release];
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

- (UIView *)createCoverView
{
    UIView *coverView = [[UIView alloc] init];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(hide)];
    [coverView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(panHide:)];
    [coverView addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
    
    return [coverView autorelease];
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
    
    for (UIGestureRecognizer *gestureRecognizer in coverView.gestureRecognizers) {
        [coverView removeGestureRecognizer:gestureRecognizer];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        
        UIView *contentView = revealEntry->contentView;
        [[self superview] sendSubviewToBack:contentView];
        
        NSValue *originalFrame = revealEntry->originalFrame;
        self.frame = [originalFrame CGRectValue];
        
    } completion:^(BOOL finished){
        
        HBRevealEntry *revealEntry = objc_getAssociatedObject(self, &REVEAL_ENTRY);
        UIView *contentView = revealEntry->contentView;
        
        UIView *coverView = revealEntry->coverView;
        [coverView removeFromSuperview];
        
        void (^hideCallback)(UIView *) = revealEntry->hideCallback;
        if (hideCallback) {
            hideCallback(contentView);
        }
        
        [contentView removeFromSuperview];
        
        objc_setAssociatedObject(self, &REVEAL_ENTRY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)reveal:(UIView *)contentView slide:(HBRevealSlide)slide hideCallback:(void (^)(UIView *))hideCallback
{
    if (!contentView)
    {
        [self hide];
        return;
    }
    
    HBRevealEntry *revealEntry = [[HBRevealEntry alloc] init];
    
    if (hideCallback) {
        revealEntry->hideCallback = [hideCallback copy];
    }
    
    CGRect frame = self.frame;
    revealEntry->originalFrame = [[NSValue valueWithCGRect:frame] retain];
    
    UIView *coverView = [self createCoverView];
    CGRect coverFrame = frame;
    coverFrame.origin = CGPointZero;
    coverView.frame = coverFrame;
    [self addSubview:coverView];
    revealEntry->coverView = [coverView retain];
    
    [[self superview] insertSubview:contentView belowSubview:self];
    revealEntry->contentView = [contentView retain];
    
    CGRect contentFrame = contentView.frame;
    contentFrame.origin = frame.origin;
    if (slide == kSlideLeft) {
        contentFrame.origin.x += frame.size.width - contentFrame.size.width;
    }
    contentView.frame = contentFrame;
    
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
        UIView *contentView = revealEntry->contentView;
        [[self superview] bringSubviewToFront:contentView];
    
    }];
}

@end
