/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()
@property (nonatomic,retain) UIView * headerView;
@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSArray* weekdayLabels;
@property (nonatomic,retain) KalGridView *gridView;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) UIImageView *shadowView;
@property (nonatomic,retain) KalLogic *logic;

@property (nonatomic,retain) UIView * contentView;

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
@end

static const CGFloat kHeaderHeight = 35.f;

@implementation KalView

- (id)initWithFrame:(CGRect)frame dataSource:(id<KalDataSource>)source delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate = theDelegate;
        self.dataSource = source;
        
        self.logic = theLogic;
        [self.logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        self.headerView = [[UIView alloc] initWithFrame:frame];
        self.headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.headerView.accessibilityIdentifier = @"KalHeaderView";
        [self addSubviewsToHeaderView:self.headerView];
        [self addSubview:self.headerView];
        
        self.contentView = [[UIView alloc] initWithFrame:frame];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.contentView.accessibilityIdentifier = @"KalContentView";
        [self addSubviewsToContentView:self.contentView];
        [self addSubview:self.contentView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
  [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
  return nil;
}

#pragma mark - events

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [self.gridView slideDown]; }
- (void)slideUp { [self.gridView slideUp]; }

- (void)showPreviousMonth
{
    if (!self.gridView.transitioning)
        [self.delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
    if (!self.gridView.transitioning)
        [self.delegate showFollowingMonth];
}

#pragma mark - setup frame and geometry

- (void)setupFrame:(CGRect)frame{
    CGRect containerFrame = frame;
    
    self.tileSize = CGSizeMake(frame.size.width/7., 44.f );
    
    //frame.size.width = 7 * self.tileSize.width;
    self.gridView.tileSize = self.tileSize;
    
    self.frame = containerFrame;
    
    [self setupHeaderViewFrame:containerFrame];
    [self setupContentViewFrame:containerFrame];
    
    self.headerView.backgroundColor = [self.dataSource backgroundColor];
    self.contentView.backgroundColor = [self.dataSource backgroundColor];
}

-(void)setupHeaderViewFrame:(CGRect)frame{
    
    CGFloat xOffset = 0.f;
    for (UILabel * one in self.weekdayLabels) {
        //        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, self.tileSize.width, kHeaderHeight - 29.f);
        CGFloat weekdayY = frame.origin.y;
        CGRect weekdayFrame = CGRectMake(xOffset, weekdayY, self.tileSize.width, kHeaderHeight);
        one.frame = weekdayFrame;
        xOffset += self.tileSize.width;
        one.backgroundColor = [self.dataSource backgroundColor];
        one.textColor = [self.dataSource weekdayTextColor];
    }
}

-(void)setupContentViewFrame:(CGRect)frame{
    CGRect contentFrame = frame;
    contentFrame.size.width = frame.size.width;
    contentFrame.origin.y += kHeaderHeight;
    self.contentView.frame = contentFrame;

    self.width = frame.size.width;
    
    CGRect gridFrame = self.gridView.frame;
    gridFrame.size.width = frame.size.width;
    self.gridView.frame = gridFrame;
    [self.gridView setupFrame:gridFrame];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.width = frame.size.width;
    self.tableView.frame = tableFrame;
    [self.gridView sizeToFit];
    
}

#pragma mark - add Subviews

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
    
    // Header background gradient
    headerView.backgroundColor = [self.dataSource backgroundColor];
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
    NSCalendar * cal = [NSDate cc_calculationCalendar];
    NSUInteger firstWeekday = [cal firstWeekday];
    NSUInteger i = firstWeekday - 1;
    NSMutableArray * labels = [NSMutableArray arrayWithCapacity:7];
    for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 46.f, i = (i+1)%7) {
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 29.f);
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
        weekdayLabel.backgroundColor = [self.dataSource backgroundColor];
        weekdayLabel.font = [self.dataSource boldSystemFontOfSize:16.f];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.textColor = [self.dataSource weekdayTextColor];
        weekdayLabel.text = [weekdayNames objectAtIndex:i];
        [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
        [headerView addSubview:weekdayLabel];
        [labels addObject:weekdayLabel];
    }
    self.weekdayLabels = labels;
    [self setupHeaderViewFrame:headerView.frame];
}


- (void)addSubviewsToContentView:(UIView *)contentView
{
    // Both the tile grid and the list of events will automatically lay themselves
    // out to fit the # of weeks in the currently displayed month.
    // So the only part of the frame that we need to specify is the width.
    CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);
    
    // The tile grid (the calendar body)
    self.gridView = [[KalGridView alloc] initWithFrame:self.frame dataSource:self.dataSource logic:self.logic delegate:self.delegate];
    [self.gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [contentView addSubview:self.gridView];
    
    // The list of events for the selected day
    self.tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:self.tableView];
    
    // Trigger the initial KVO update to finish the contentView layout
    [self.gridView sizeToFit];
    [self setupContentViewFrame:contentView.frame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.gridView && [keyPath isEqualToString:@"frame"]) {
        
        /* Animate tableView filling the remaining space after the
         * gridView expanded or contracted to fit the # of weeks
         * for the month that is being displayed.
         *
         * This observer method will be called when gridView's height
         * changes, which we know to occur inside a Core Animation
         * transaction. Hence, when I set the "frame" property on
         * tableView here, I do not need to wrap it in a
         * [UIView beginAnimations:context:].
         */
        CGFloat gridBottom = self.gridView.top + self.gridView.height;
        CGRect frame = self.tableView.frame;
        frame.origin.y = gridBottom;
        frame.size.height = self.tableView.superview.height - gridBottom;
        self.tableView.frame = frame;
        if (self.shadowView) {
            self.shadowView.top = gridBottom;
        }
        
    } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)jumpToSelectedMonth {
    
    [self.gridView jumpToSelectedMonth];
    
    //
    NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    NSUInteger firstWeekday = [[NSDate cc_calculationCalendar] firstWeekday];
    NSUInteger il = firstWeekday - 1;
    for (NSUInteger i=0; i<self.weekdayLabels.count; i++) {
        UILabel * label = self.weekdayLabels[i];
        if (il < weekdayNames.count) {
            label.text = weekdayNames[il];
        }
        il = (il+1)%7;
    }
    
}

- (KalDate *)selectedDate
{
    return self.gridView.selectedDate;
    
}

- (void)selectDate:(KalDate *)date
{
    [self.gridView selectDate:date];
    
}

- (BOOL)isSliding { return self.gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates andSource:(id<KalDataSource>)source { [self.gridView markTilesForDates:dates andSource:source]; }


- (void)dealloc
{
    [self.logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
    
    
    [self.gridView removeObserver:self forKeyPath:@"frame"];
}

@end
