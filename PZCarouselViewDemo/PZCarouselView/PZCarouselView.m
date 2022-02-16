//
//  PZCarouselView.m
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import "PZCarouselView.h"
#import "PZCarouselFlowLayout.h"

@interface PZCarouselCollectionView ()<UIGestureRecognizerDelegate>
@property(nonatomic) void (^ _Nullable tapCallback) (void);
@end

@implementation PZCarouselCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        tap.delegate = self;
    }
    return self;
}

-(void) handleTap:(UITapGestureRecognizer *) tap {
    if (!_tapCallback) {
        return;
    }
    self.tapCallback();
}

#pragma mark - tap delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] == NO) {
        return YES;
    }
    
    if ([[touch view] isKindOfClass:[UICollectionView class]]) {
        return YES;
    }
    
    return NO;
}

@end

@interface PZProxy : NSProxy
@property (nonatomic, weak) id _Nullable target;
- (instancetype)init:(id)target;
+ (instancetype)proxyWith:(id)target;
@end

@implementation PZProxy
- (instancetype)init:(id)target {
    self.target = target;
    return self;
}
+ (instancetype)proxyWith:(id)target {
    return [[PZProxy alloc] init:target];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.target respondsToSelector:invocation.selector]) {
        
        [invocation invokeWithTarget:self.target];
    }
}

@end

@interface PZCarouselView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,readwrite) PZCarouselCollectionView *pz_collectionView;
/// 轮播总数
@property(nonatomic) NSInteger numbers;
@property(nonatomic) NSInteger currentIndex;
@property(nonatomic) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL isPause;
@property(nonatomic) NSTimer *timer;
@end

@implementation PZCarouselView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//- (instancetype)initWithFrame:(CGRect)frame
//{
//
//}
-(instancetype) initWithFrame:(CGRect)frame flowLayout:(PZCarouselFlowLayout *) flowLayout {
    self = [super initWithFrame:frame];
    if (self) {
        _flowLayout = flowLayout;
        self.isAuto = NO;
        self.autoInterval = 3;
        self.isInfinite = YES;
        [self configureView];
        [self addNotification];
    }
    return self;
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.pz_collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

-(void) reloadCarousel {
    if (self.numbers < 0) {
        return;
    }
    
    [_pz_collectionView reloadData];
    [self layoutIfNeeded];
    
    if (_isInfinite) {
        [_pz_collectionView scrollToItemAtIndexPath:self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    } else {
        if (self.style == PZCarouselViewStyleDefault) {
            [_pz_collectionView scrollToItemAtIndexPath:self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        } else {
            [_pz_collectionView scrollToItemAtIndexPath:self.currentIndexPath = [NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
    }
    
    _pz_collectionView.userInteractionEnabled = YES;
    if (_isAuto) {
        [self play];
    }
}
-(void) pause {
    _isPause = YES;
    [self stop];
}
-(void) resumePlay {
    _isPause = NO;
    if (_timer) {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_autoInterval]];
    } else {
        [self play];
    }
    
}
-(void) scrollToIndex:(NSInteger) idx animation:(BOOL) animation {
    if (idx < 0 || idx >= self.numbers || idx == self.currentIndex) {
        return;
    }
    [self stop];
    self.currentIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item + (idx - _currentIndex) inSection:self.currentIndexPath.section];
    [self customScrollViewWillBeginDecelerating:_pz_collectionView animation:animation];
}

#pragma mark - private
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if (self.customPageControl == nil && self.pageControl.superview == nil) {
            [self configurePageControl];
        }
    }
}

-(void) configurePageControl {
    UIView *pageControl = self.customPageControl;
    BOOL isDefault = NO;
    
    if (!pageControl) {
        pageControl = self.pageControl;
        isDefault = YES;
    }
    if ([self.delegate respondsToSelector:@selector(PZCarousel:willAddPageControl:isDefault:)]) {
        [self.delegate PZCarousel:self willAddPageControl:pageControl isDefault:isDefault];
    } else {
        [self addSubview:pageControl];
        pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[control(20)]-0-|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"control" : pageControl}]];
        [[pageControl.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow == nil) {
        if (_isAuto) {
            [self pause];
        }
        [self adjustErrorCell:YES];
    } else {
        if (_isAuto) {
            [self resumePlay];
        }
        [self adjustErrorCell:YES];
    }
}

- (void)dealloc
{
    [self releaseTimer];
}

-(void) releaseTimer {
    [self.timer invalidate];
    self.timer = nil;
}

-(void) play {
    if (_isPause) {
        return;
    }
    if (!_isAuto) {
        return;
    }
    if (_timer) {
        [self resumePlay];
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:_autoInterval target:[PZProxy proxyWith:self] selector:@selector(scrollToNextCell) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_autoInterval]];
}

-(void) scrollToNextCell {
    if ([self actualNumbers] <= 0) {
        return;
    }
    
    NSInteger maxIdxHelper = 1;
    if (!_isInfinite && self.style != PZCarouselViewStyleDefault) {
        maxIdxHelper = 2;
    }
    if (self.currentIndexPath.item < [self actualNumbers] - maxIdxHelper) {
        NSIndexPath *nextIdx = [NSIndexPath indexPathForItem:self.currentIndexPath.item + 1 inSection:self.currentIndexPath.section];
        [_pz_collectionView scrollToItemAtIndexPath:nextIdx atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        self.currentIndexPath = nextIdx;
    } else if (!_isInfinite) {
        NSIndexPath *nextIdx = [NSIndexPath indexPathForItem:maxIdxHelper - 1 inSection:self.currentIndexPath.section];
        [_pz_collectionView scrollToItemAtIndexPath:nextIdx atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        self.currentIndexPath = nextIdx;
    }
}

-(void) stop {
    if (_timer) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

-(void) configureView {
    self.backgroundColor = [UIColor blackColor];
    self.pz_collectionView.showsVerticalScrollIndicator = NO;
    self.pz_collectionView.showsHorizontalScrollIndicator = NO;
    self.pz_collectionView.decelerationRate = 0;
}

-(void) addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) appBecomeInactive {
    [self adjustErrorCell:YES];
}

-(void) appBecomeActive {
    [self adjustErrorCell:YES];
}

/// 将离中心最近的cell居中
/// @param animated 是否动画
-(void) adjustErrorCell:(BOOL) animated {
    NSArray<NSIndexPath *> *indexPaths = [_pz_collectionView indexPathsForVisibleItems];
    CGFloat centerX = _pz_collectionView.contentOffset.x + _pz_collectionView.bounds.size.width * 0.5;
    __block CGFloat minSpacing = INT_MAX;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UICollectionViewLayoutAttributes *attr = [self.pz_collectionView layoutAttributesForItemAtIndexPath:obj];
            if(ABS(minSpacing) > ABS(attr.center.x - centerX)) {
                minSpacing = ABS(attr.center.x - centerX);
                self.currentIndexPath = attr.indexPath;
            }
    }];
    if (animated) {
        [self customScrollViewWillBeginDecelerating:_pz_collectionView animation:YES];
    }
}

-(NSInteger) calculateIndex:(NSInteger) actualIndex {
    NSInteger num = self.numbers;
    if (!_isInfinite && self.style != PZCarouselViewStyleDefault) {
        return actualIndex % [self actualNumbers] - 1;
    } else {
        return actualIndex % num;
    }
    return 0;
}

#pragma mark - collectionView delegate
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_isInfinite && self.style != PZCarouselViewStyleDefault && (indexPath.item == 0 || indexPath.item == [self actualNumbers] - 1)) {
        UICollectionViewCell *tempCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tempCell" forIndexPath:indexPath];
        tempCell.contentView.backgroundColor = [UIColor clearColor];
        return tempCell;
    }
    
    if ([self.dataSource respondsToSelector:@selector(cellForCarousel:indexPath:index:)]) {
        UICollectionViewCell *cell = [self.dataSource cellForCarousel:(PZCarouselCollectionView *)collectionView indexPath:indexPath index:[self calculateIndex:indexPath.item]];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self actualNumbers];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(PZCarousel:didSelectIndex:)]) {
        [self.delegate PZCarousel:self didSelectIndex:[self calculateIndex:indexPath.item]];
    }
    [self adjustErrorCell:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (@available(iOS 14.0, *)) {
        scrollView.pagingEnabled = NO;
    } else {
        scrollView.pagingEnabled = YES;
    }
    if (_isAuto) {
        [self stop];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger num = [self numbers];
    
    if (num <= 0) {
        return;
    }
    if (!_isInfinite) {
        NSInteger maxIndex = num - 1;
        NSInteger minIndex = 0;
        if(self.style != PZCarouselViewStyleDefault)
        {
            // 后面有一个占位cell, 所以减2, 不是减1
            maxIndex = [self actualNumbers] - 2;
            // 前面有一个占位cell, 所以下标是从1开始
            minIndex = 1;
        }
        if (velocity.x == 0) {
            [self velocityZero];
            return;
        }
        if (velocity.x > 0 && self.currentIndexPath.item == maxIndex) {
            return;
        }
        if (velocity.x < 0 && self.currentIndexPath.item == minIndex) {
            return;
        }
    }
        if (velocity.x > 0) {
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item + 1 inSection:self.currentIndexPath.section];
        } else if (velocity.x < 0) {
            self.currentIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
        } else {
            [self velocityZero];
        }
}

/// velocity == 0时的处理
- (void)velocityZero {
    // 还有一种情况,当滑动后手指按住不放,然后松开,此时的加速度其实是为0的
    [self adjustErrorCell:NO];
    if (@available(iOS 14.0, *)) {
        // iOS14以前,就算加速度为0,后续系统会还是会走scrollViewWillBeginDecelerating:回调
        // 但是iOS14以后,加速度为0时,不会在后续执行回调.这里手动触发一下
        [self scrollViewWillBeginDecelerating:self.pz_collectionView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self customScrollViewWillBeginDecelerating:scrollView animation:YES];
}

- (void)customScrollViewWillBeginDecelerating:(UIScrollView *)scrollView animation:(BOOL) animated {
    if (!_isInfinite) {
        if (self.style != PZCarouselViewStyleDefault) {
            if (self.currentIndexPath.item == 0) {
                self.currentIndexPath = [NSIndexPath indexPathForItem:1 inSection:self.currentIndexPath.section];
            }
            if (self.currentIndexPath.item == [self actualNumbers] - 1) {
                self.currentIndexPath = [NSIndexPath indexPathForItem:[self actualNumbers] - 2 inSection:self.currentIndexPath.section];
            }
        }
    }
    [_pz_collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    if (!animated) {
        [self customScrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrollView.pagingEnabled = NO;
    if (_isAuto) {
        [self play];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self customScrollViewDidEndScrollingAnimation:scrollView];
}

- (void)customScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pz_collectionView.userInteractionEnabled = YES;
    scrollView.pagingEnabled = NO;
    if (_isAuto) {
        [self play];
    }
    if (_isInfinite) {
        [self checkOutOfBounds];
    }
}

-(void) checkOutOfBounds {
    if ([self numbers] <= 0) {return;}
    
    BOOL scroll = NO;
    NSInteger index = self.currentIndex;
    
    // 越界检查
    if(self.currentIndexPath.item == [self actualNumbers] - 1) {
        index = [self calculateIndex:self.currentIndexPath.item] - 1; //最后一张
        scroll = YES;
    }else if(self.currentIndexPath.item == 0) {
        index = [self calculateIndex:self.currentIndexPath.item]; //第一张
        scroll = YES;
    }
    
//    _pz_collectionView.userInteractionEnabled = YES;
    if (scroll == NO) {
        return;
    }
    
    NSIndexPath *origin = [self originalIndexPath];
    self.currentIndexPath = [NSIndexPath indexPathForRow:origin.item + index inSection:origin.section];
    [_pz_collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

-(NSIndexPath *) originalIndexPath {
    NSInteger num = [self numbers];
    if (num <= 0) {
        return [[NSIndexPath alloc] initWithIndex:0];
    }
    
    if (!_isInfinite) {
        NSInteger row = self.flowLayout.style == PZCarouselViewStyleDefault ? 0 : 1;
        self.currentIndexPath = [NSIndexPath indexPathForItem:row inSection:0];
        return self.currentIndexPath;
    }
    
    NSInteger centerIndex = [self actualNumbers] / num; //一共有多少组
    
    if (centerIndex == 0) {
        // 异常, 一组都没有
        NSAssert(true, @"计算起始下标异常, 分组不足一组.");
        return self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    if (centerIndex == 1) {
        return self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
        
    // 取中间一组展示
    self.currentIndexPath = [NSIndexPath indexPathForItem:centerIndex / 2 * num inSection:0];
    return self.currentIndexPath;
}

#pragma mark - getter
- (PZCarouselCollectionView *)pz_collectionView {
    if (!_pz_collectionView) {
        PZCarouselCollectionView *collectionView = [[PZCarouselCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self addSubview:collectionView];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"tempCell"];
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = @{@"view" : collectionView};
//        NSDictionary *margins = @{@"top" : @(0),
//                                  @"bottom" : @(0)
//                                  };
        NSString *str = @"H:|-0-[view]-0-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        str = @"V:|-0-[view]-0-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:str
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        
        __weak typeof(self) weakSelf = self;
        [collectionView setTapCallback:^{
                    [weakSelf adjustErrorCell:YES];
        }];
        _pz_collectionView = collectionView;
    }
    return _pz_collectionView;
}

- (PZCarouselViewStyle)style {
    if (!_flowLayout.style) {
        return PZCarouselViewStyleUnknown;
    }
    return _flowLayout.style;
}


/// 业务需求加载个数
- (NSInteger)numbers {
    if ([self.dataSource respondsToSelector:@selector(numbersForCarousel:)]) {
        NSInteger num = [self.dataSource numbersForCarousel:self];
        if (self.customPageControl) {
            [_customPageControl setNumberOfPages:num];
        } else {
            [self.pageControl setNumberOfPages:num];
        }
        return num;
    }
    return 0;
}


/// 实际加载的轮播图个数
- (NSInteger)actualNumbers {
    NSInteger num = [self numbers];
    if (num <= 0) {
        return 0;
    }
    
    //默认可滑动
    [_pz_collectionView setScrollEnabled:YES];
    if (_isInfinite) {
        if (num == 1) {
            [_pz_collectionView setScrollEnabled:NO];
            return num;
        }
        return 300;
    } else {
        if (self.style == PZCarouselViewStyleDefault) {
            return num;
        } else {
            if (num == 1) {
                [_pz_collectionView setScrollEnabled:NO];
                
            }
            return num + 2;
        }
    }
    
    
}

- (UIPageControl *)pageControl {
    if(!_pageControl) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

#pragma mark - setter
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.pz_collectionView.backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    _currentIndexPath = currentIndexPath;
    
    self.currentIndex = [self calculateIndex:currentIndexPath.item];
    if (_customPageControl) {
        [_customPageControl setCurrentPage:[self calculateIndex:currentIndexPath.item]];
    } else {
        [self.pageControl setCurrentPage:[self calculateIndex:currentIndexPath.item]];
    }
}

- (void)setCustomPageControl:(UIView<PZCarouselPageControl> *)customPageControl {
    if (_customPageControl != customPageControl) {
        [_customPageControl removeFromSuperview];
    } else {
        return;
    }
    _customPageControl = customPageControl;
    if (_customPageControl && _pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    [self configurePageControl];
}

@end
