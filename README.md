## Usage
`#import "UIView+HBReveal.h"`

```objc
UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"SidebarView"
                                                     owner:self options:nil] lastObject];

// show the sidebar
[self.view reveal:contentView];

// hide the sidebar
[self.view reveal:nil];
```

Demo:  
[![HBReveal Demo][t9ENROH_mis_img]][t9ENROH_mis_link]
[t9ENROH_mis_link]: http://www.youtube.com/watch?v=t9ENROH_mis "HBReveal Demo"
[t9ENROH_mis_img]: http://img.youtube.com/vi/t9ENROH_mis/3.jpg "HBReveal Demo"
