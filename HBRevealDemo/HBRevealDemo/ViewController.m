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

#import "ViewController.h"

#import "UIView+HBReveal.h"

@implementation ViewController

- (IBAction)revealSidebarLeft:(id)sender
{
    UIView *sidebarView = [[[NSBundle mainBundle] loadNibNamed:@"SidebarView"
                                                         owner:self options:nil] lastObject];
    [self.view reveal:sidebarView slide:kSlideRight hideCallback:nil];
}

- (IBAction)revealSidebarRight:(id)sender
{
    UIView *sidebarView = [[[NSBundle mainBundle] loadNibNamed:@"SidebarView"
                                                         owner:self options:nil] lastObject];
    [self.view reveal:sidebarView slide:kSlideLeft hideCallback:nil];
}

- (IBAction)hideSidebar:(id)sender
{
    [self.view reveal:nil slide:kSlideLeft hideCallback:nil];
}

- (IBAction)revealDrawerLeft:(id)sender
{
    UIView *drawerView = [[[NSBundle mainBundle] loadNibNamed:@"DrawerView"
                                                        owner:self options:nil] lastObject];
    [self.outerDrawerView reveal:drawerView slide:kSlideRight hideCallback:nil];
}

- (IBAction)revealDrawerRight:(id)sender
{
    UIView *drawerView = [[[NSBundle mainBundle] loadNibNamed:@"DrawerView"
                                                        owner:self options:nil] lastObject];
    [self.outerDrawerView reveal:drawerView slide:kSlideLeft hideCallback:nil];
}

- (IBAction)hideDrawer:(id)sender
{
    [self.outerDrawerView reveal:nil slide:kSlideRight hideCallback:nil];
}

@end
