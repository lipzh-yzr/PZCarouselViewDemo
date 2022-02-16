//
//  PZCarouselFlowLayout.h
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PZCarouselViewStyle) {
    PZCarouselViewStyleUnknown,
    PZCarouselViewStyleDefault,//!<默认样式
    PZCarouselViewStyle_H_1,    //!<中间一张图正常大小,前后2张图会缩放
    PZCarouselViewStyle_H_2 //!<中间一张图放大,前后2张图正常大小
};

@interface PZCarouselFlowLayout : UICollectionViewFlowLayout
@property(nonatomic) CGFloat itemSpacing_H;
@property(nonatomic) CGFloat itemWidth;
@property(nonatomic) PZCarouselViewStyle style;

/// 当样式为H_2时，放大的比例
@property(nonatomic) CGFloat scaleFactor;

-(instancetype) initWithStyle:(PZCarouselViewStyle) style;
@end

NS_ASSUME_NONNULL_END
