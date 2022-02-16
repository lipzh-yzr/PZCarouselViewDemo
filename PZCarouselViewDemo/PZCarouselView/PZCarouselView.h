//
//  PZCarouselView.h
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import <UIKit/UIKit.h>
#import "PZCarouselFlowLayout.h"
@class PZCarouselView;
@class PZCarouselCollectionView;

@protocol PZCarouselPageControl <NSObject>
@property(nonatomic) NSInteger currentPage;
@property(nonatomic) NSInteger numberOfPages;
@optional

@end

@protocol PZCarouselDelegate <NSObject>
-(void) PZCarousel:(PZCarouselView *) pz_carousel didSelectIndex:(NSInteger) idx;

@optional
-(void) PZCarousel:(PZCarouselView *) pz_carousel willAddPageControl:(UIView<PZCarouselPageControl> *) pageControl isDefault:(BOOL) isDefault;
@end

@protocol PZCarouselDatasource <NSObject>
-(NSInteger) numbersForCarousel:(PZCarouselView *) pz_carousel;

-(UICollectionViewCell *) cellForCarousel:(PZCarouselCollectionView *) pz_carousel indexPath:(NSIndexPath *) indexPath index:(NSInteger) idx;
@optional

@end

NS_ASSUME_NONNULL_BEGIN
@interface PZCarouselCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@end

@interface PZCarouselView : UIView
@property(nonatomic,weak) id<PZCarouselDatasource> dataSource;
@property(nonatomic,weak) id<PZCarouselDelegate> delegate;
@property(nonatomic,readonly) PZCarouselViewStyle style;
@property(nonatomic,readonly) PZCarouselFlowLayout *flowLayout;
@property(nonatomic,readonly) PZCarouselCollectionView *pz_collectionView;

/// 是否自动轮播
@property(nonatomic) BOOL isAuto;

/// 是否无限轮播衔接
@property(nonatomic) BOOL isInfinite;
@property(nonatomic) NSTimeInterval autoInterval;
@property(nonatomic) UIPageControl *pageControl;
@property(nonatomic) UIView<PZCarouselPageControl> *customPageControl;

-(instancetype) initWithFrame:(CGRect)frame flowLayout:(PZCarouselFlowLayout *) flowLayout;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
-(void) reloadCarousel;
-(void) pause;
-(void) resumePlay;
-(void) scrollToIndex:(NSInteger) idx animation:(BOOL) animation;
@end



NS_ASSUME_NONNULL_END
