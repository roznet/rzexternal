/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>
#import "KalDataSource.h"

@class KalTileView, KalMonthView, KalLogic, KalDate;
@protocol KalViewDelegate;

/*
 *    KalGridView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalView).
 *
 */
@interface KalGridView : UIView
{
}

@property (nonatomic, readonly) BOOL transitioning;
@property (nonatomic, readonly) KalDate *selectedDate;
@property (nonatomic, assign) CGSize tileSize;
@property (nonatomic, weak) id<KalDataSource> dataSource;
@property (nonatomic, weak) id<KalViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame dataSource:(id<KalDataSource>)source logic:(KalLogic *)logic delegate:(id<KalViewDelegate>)delegate;
- (void)selectDate:(KalDate *)date;
- (void)markTilesForDates:(NSArray *)dates andSource:(id<KalDataSource>)source;

// These 3 methods should be called *after* the KalLogic
// has moved to the previous or following month.
- (void)slideUp;
- (void)slideDown;
- (void)jumpToSelectedMonth;    // see comment on KalView
-(void)setupFrame:(CGRect)frame;
@end
