## Usage
Include header:
`#import "UIView+HBReveal.h"`

```objc
UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"SidebarView"
                                                     owner:self options:nil] lastObject];
[self.view reveal:contentView];
```
