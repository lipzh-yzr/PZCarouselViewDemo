//
//  PZCarouselFlowLayout.m
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import "PZCarouselFlowLayout.h"

@interface PZCarouselFlowLayout ()
@property(nonatomic) CGFloat defaultItemWidth;

@end


@implementation PZCarouselFlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemSpacing_H = 0;
        self.scaleFactor = 0.8;
    }
    return self;
}
-(instancetype) initWithStyle:(PZCarouselViewStyle) style {
    self = [self init];
    if (self) {
        self.style = style;
        
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.style == PZCarouselViewStyleUnknown) {
        return NO;
    }

    if (self.style == PZCarouselViewStyleDefault) {
        return NO;
    }

    if (self.style == PZCarouselViewStyle_H_1) {
        return NO;
    }
    
    return YES;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    switch (_style) {
        case PZCarouselViewStyleDefault:{
            CGFloat width = CGRectGetWidth(self.collectionView.bounds);
            CGFloat height = CGRectGetHeight(self.collectionView.bounds);
            self.itemWidth = width;
            self.itemSize = CGSizeMake(width, height);
            self.minimumLineSpacing = self.itemSpacing_H;
            
        }
            
            break;
        case PZCarouselViewStyle_H_1:{
            CGFloat width = self.itemWidth <= 0 ? self.defaultItemWidth : self.itemWidth;
            CGFloat height = CGRectGetHeight(self.collectionView.bounds);
            self.itemWidth = width;
            self.itemSize = CGSizeMake(width, height);
            self.minimumLineSpacing = self.itemSpacing_H;
        }
            
            break;
        case PZCarouselViewStyle_H_2:{
            CGFloat width = self.itemWidth <= 0 ? self.defaultItemWidth : self.itemWidth;
            CGFloat height = CGRectGetHeight(self.collectionView.bounds);
            self.itemWidth = width;
            self.itemSize = CGSizeMake(width, height);
            CGFloat padding = width * (1 - self.scaleFactor) * 0.5;
//            self.minimumInteritemSpacing = self.itemSpacing_H - padding;
            self.minimumLineSpacing = self.itemSpacing_H - padding;
        }
            
            break;
            
        default:
            break;
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.style == PZCarouselViewStyleUnknown ||
        self.style == PZCarouselViewStyleDefault ||
        self.style == PZCarouselViewStyle_H_1) {
        
        return [super layoutAttributesForElementsInRect:rect];
    }
    
    NSArray<UICollectionViewLayoutAttributes *> *arr = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    
    CGFloat centerX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame) * 0.5;
    __block CGFloat maxScale = 0;
    __block UICollectionViewLayoutAttributes *attrs = nil;
    [arr enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectGetMinY(obj.frame) != 0) {
            obj.frame = CGRectMake(obj.frame.origin.x, 0, obj.frame.size.width, obj.frame.size.height);
        }
            CGFloat space = ABS(obj.center.x - centerX);
            space = MIN(space, self.itemWidth);
            obj.zIndex = 0;
            if (space >= 0) {
                CGFloat scale = (self.scaleFactor - 1)/ self.itemWidth * space + 1;
                obj.transform = CGAffineTransformMakeScale(scale, scale);
                if (maxScale < scale) {
                    maxScale = scale;
                    attrs = obj;
                }
            }
    }];
    if (attrs) {
        attrs.zIndex = 1;
    }
    
    return arr;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    return proposedContentOffset;
}

- (CGFloat)defaultItemWidth {
    switch (self.style) {
        case PZCarouselViewStyleUnknown:
        case PZCarouselViewStyleDefault:
            return self.collectionView.frame.size.width;
            break;
        case PZCarouselViewStyle_H_1:
        case PZCarouselViewStyle_H_2:
            return self.collectionView.frame.size.width * 0.75;
            break;
        default:
            break;
    }
}

- (void)setScaleFactor:(CGFloat)scaleFactor {
    if (scaleFactor < 0) {
        _scaleFactor = 0.1;
    } else if(scaleFactor > 1){
        _scaleFactor = 1;
    }
    _scaleFactor = scaleFactor;
}
@end
