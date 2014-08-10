#import "MUKDataSourceAppendContentView.h"

@interface MUKDataSourceAppendContentView ()
@property (nonatomic, weak, readwrite) UILabel *textLabel;
@property (nonatomic, weak, readwrite) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation MUKDataSourceAppendContentView

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
    [self layoutTextLabelWithTrailingActivityIndicatorView];
}

#pragma mark - Accessors

- (void)setLeftMargin:(CGFloat)leftMargin {
    if (_leftMargin != leftMargin) {
        _leftMargin = leftMargin;
        [self layoutTextLabelWithTrailingActivityIndicatorView];
    }
}

#pragma mark - Private

static void CommonInit(MUKDataSourceAppendContentView *me) {
    [me insertAllSubviews];
    me->_leftMargin = 15.0f;
}

- (void)insertAllSubviews {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 1;
    [self addSubview:textLabel];
    self.textLabel = textLabel;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    [self addSubview:spinner];
    self.activityIndicatorView = spinner;
}

- (void)layoutTextLabelWithTrailingActivityIndicatorView {
    [self.textLabel sizeToFit];
    CGRect frame = self.textLabel.frame;
    frame.origin.x = self.leftMargin;
    frame.origin.y = roundf(CGRectGetMidY(self.bounds) - CGRectGetHeight(frame)/2.0f);
    self.textLabel.frame = frame;
    
    CGFloat const textToSpinnerMargin = 7.0f;
    frame = self.activityIndicatorView.frame;
    frame.origin.x = CGRectGetMaxX(self.textLabel.frame) + textToSpinnerMargin;
    frame.origin.y = roundf(CGRectGetMidY(self.textLabel.frame) - CGRectGetHeight(frame)/2.0f);
    self.activityIndicatorView.frame = frame;
}

@end
