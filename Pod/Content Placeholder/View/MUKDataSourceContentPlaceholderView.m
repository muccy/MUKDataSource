#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKDataSourceContentPlaceholderView ()
@property (nonatomic, weak, readwrite) UILabel *titleLabel, *textLabel;
@property (nonatomic, weak, readwrite) UIImageView *imageView;
@end

@implementation MUKDataSourceContentPlaceholderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CommonInit(self);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets const titleLabelMinimumMargins = [self titleLabelMinimumMargins];
    CGFloat const availableWidth = CGRectGetWidth(self.bounds) - titleLabelMinimumMargins.left - titleLabelMinimumMargins.right;
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    if (frame.size.width > availableWidth) {
        frame.size.width = availableWidth;
    }
    self.titleLabel.frame = frame;
    
    frame = self.textLabel.frame;
    frame.size.width = availableWidth;
    self.textLabel.frame = frame;
    [self.textLabel sizeToFit];
    
    [self.imageView sizeToFit];
    
    // Center horizontally
    frame = self.titleLabel.frame;
    frame.origin.x = roundf(CGRectGetMidX(self.bounds) - CGRectGetWidth(frame)/2.0f);
    self.titleLabel.frame = frame;
    
    frame = self.textLabel.frame;
    frame.origin.x = roundf(CGRectGetMidX(self.bounds) - CGRectGetWidth(frame)/2.0f);
    self.textLabel.frame = frame;
    
    frame = self.imageView.frame;
    frame.origin.x = roundf(CGRectGetMidX(self.bounds) - CGRectGetWidth(frame)/2.0f);
    self.imageView.frame = frame;
    
    // Center vertically as a block
    CGFloat const imageToTitleMargin = titleLabelMinimumMargins.top;
    CGFloat const titleToTextMargin = titleLabelMinimumMargins.bottom;
    CGFloat const totalVerticalHeight = CGRectGetHeight(self.imageView.frame) + imageToTitleMargin + CGRectGetHeight(self.titleLabel.frame) + titleToTextMargin + CGRectGetHeight(self.textLabel.frame);
    CGFloat const remainingVerticalSpace = CGRectGetHeight(self.bounds) - totalVerticalHeight;
    
    frame = self.imageView.frame;
    frame.origin.y = roundf(remainingVerticalSpace/2.0f);
    self.imageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.imageView.frame) + imageToTitleMargin;
    self.titleLabel.frame = frame;
    
    frame = self.textLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + titleToTextMargin;
    self.textLabel.frame = frame;
}

- (UIEdgeInsets)titleLabelMinimumMargins {
    return UIEdgeInsetsMake(10.0f, 5.0f, 5.0f, 5.0f);
}

#pragma mark - Private

static void CommonInit(MUKDataSourceContentPlaceholderView *me) {
    [me insertAllSubviews];
}

- (void)insertAllSubviews {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

    UIColor *textColor;
    if (@available(iOS 13, *)) {
        textColor = UIColor.labelColor;
    }
    else {
        textColor = UIColor.darkGrayColor;
    }

    label.textColor = textColor;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    label.numberOfLines = 1;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    
    if (@available(iOS 13, *)) {
        textColor = UIColor.secondaryLabelColor;
    }
    else {
        textColor = UIColor.lightGrayColor;
    }
    
    label.textColor = textColor;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.textLabel = label;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    self.imageView = imageView;
}

@end
