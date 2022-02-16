//
//  ViewController.m
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import "ViewController.h"
#import "PZCarouselView/PZCarouselView.h"
#import "Masonry.h"

@interface ViewController () <PZCarouselDelegate,PZCarouselDatasource>
@property(nonatomic) PZCarouselView *carouselView;
@property(nonatomic) NSMutableArray<NSString *> *imageArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    PZCarouselFlowLayout *flowLayout = [[PZCarouselFlowLayout alloc] initWithStyle:PZCarouselViewStyle_H_2];
    flowLayout.itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 100;
    flowLayout.itemSpacing_H = -20;
    
    _carouselView = [[PZCarouselView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 400) flowLayout:flowLayout];
    [self.view addSubview:_carouselView];
    _carouselView.delegate = self;
    _carouselView.dataSource = self;
    [_carouselView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    _imageArr = @[].mutableCopy;
    
    _carouselView.isAuto = YES;
    _carouselView.isInfinite = NO;
    _carouselView.autoInterval = 1;
    
    [self getNetworkData];
}

-(void) getNetworkData {
    for (NSInteger i = 1; i <= 5; i++) {
        [_imageArr addObject:[NSString stringWithFormat:@"0%li.jpg", i]];
    }
    [_carouselView reloadCarousel];
}

- (UICollectionViewCell *)cellForCarousel:(PZCarouselCollectionView *)pz_carousel indexPath:(NSIndexPath *)indexPath index:(NSInteger)idx {
    UICollectionViewCell *cell = [pz_carousel dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImage *img = [UIImage imageNamed:_imageArr[idx]];
    if ([cell.contentView.subviews.lastObject isKindOfClass:UIImageView.class]) {
        ((UIImageView *)cell.contentView.subviews.lastObject).image = img;
    } else {
        
        UIImageView *image = [[UIImageView alloc] initWithImage:img];
        image.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:image];
//        [NSLayoutConstraint activateConstraints:@[[image.topAnchor constraintEqualToAnchor:cell.topAnchor], [image.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor], [image.leftAnchor constraintEqualToAnchor:cell.leftAnchor], [image.rightAnchor constraintEqualToAnchor:cell.rightAnchor]]];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
        }];
    }
    return cell;
}

- (NSInteger)numbersForCarousel:(PZCarouselView *)pz_carousel {
    return _imageArr.count;
}

- (void)PZCarousel:(PZCarouselView *)pz_carousel didSelectIndex:(NSInteger)idx {
    NSLog(@"did select");
}


@end
