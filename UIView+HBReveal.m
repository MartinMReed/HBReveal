/* Copyright (c) 2013 Martin M Reed
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

static const NSString *CONTAINER_VIEW;
static const NSString *COVER_VIEW;
static const NSString *ORIGINAL_FRAME;

@implementation UIView (HBReveal)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *containerView = objc_getAssociatedObject(self, &CONTAINER_VIEW);
    
    if (containerView)
    {
        CGRect bounds = self.bounds;
        CGRect containerBounds = containerView.bounds;
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
                                                                                           action:@selector(hide)];
    [coverView addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release];
    
    return [coverView autorelease];
}

- (void)hide
{
    UIView *coverView = objc_getAssociatedObject(self, &COVER_VIEW);
    
    for (UIGestureRecognizer *gestureRecognizer in coverView.gestureRecognizers) {
        [coverView removeGestureRecognizer:gestureRecognizer];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        NSValue *originalFrame = objc_getAssociatedObject(self, &ORIGINAL_FRAME);
        self.frame = [originalFrame CGRectValue];
        objc_setAssociatedObject(self, &ORIGINAL_FRAME, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        UIView *containerView = objc_getAssociatedObject(self, &CONTAINER_VIEW);
        UIView *contentView = [containerView.subviews objectAtIndex:0];
        CGRect contentFrame = contentView.frame;
        contentFrame.origin = CGPointMake(-1 * contentFrame.size.width, contentFrame.origin.y);
        contentView.frame = contentFrame;
        
    } completion:^(BOOL finished){
        
        UIView *coverView = objc_getAssociatedObject(self, &COVER_VIEW);
        objc_setAssociatedObject(self, &COVER_VIEW, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [coverView removeFromSuperview];
        
        UIView *containerView = objc_getAssociatedObject(self, &CONTAINER_VIEW);
        objc_setAssociatedObject(self, &COVER_VIEW, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [containerView removeFromSuperview];
    }];
}

- (void)reveal:(UIView *)contentView
{
    if (!contentView)
    {
        [self hide];
        return;
    }
    
    UIView *containerView = [[UIView alloc] init];
    [containerView setAutoresizesSubviews:NO];
    [containerView setClipsToBounds:YES];
    [containerView addSubview:contentView];
    [self addSubview:containerView];
    objc_setAssociatedObject(self, &CONTAINER_VIEW, containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGRect frame = self.frame;
    objc_setAssociatedObject(self, &ORIGINAL_FRAME, [NSValue valueWithCGRect:frame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIView *coverView = [self createCoverView];
    CGRect coverFrame = frame;
    coverFrame.origin = CGPointMake(0, 0);
    coverView.frame = coverFrame;
    [self addSubview:coverView];
    objc_setAssociatedObject(self, &COVER_VIEW, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGRect contentFrame = contentView.frame;
    contentFrame.origin = CGPointMake(-1 * contentFrame.size.width, contentFrame.origin.y);
    contentView.frame = contentFrame;
    
    CGRect containerFrame = containerView.frame;
    containerFrame.size = contentView.frame.size;
    containerFrame.origin = CGPointMake(frame.size.width, 0);
    containerView.frame = containerFrame;
    
    [containerView release];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        UIView *containerView = objc_getAssociatedObject(self, &CONTAINER_VIEW);
        UIView *contentView = [containerView.subviews objectAtIndex:0];
        CGRect contentFrame = contentView.frame;
        
        CGRect frame = self.frame;
        frame.origin = CGPointMake(frame.origin.x - contentFrame.size.width, frame.origin.y);
        self.frame = frame;
        
        contentFrame.origin = CGPointMake(0, contentFrame.origin.y);
        contentView.frame = contentFrame;
        
    } completion:^(BOOL finished){}];
}

@end
