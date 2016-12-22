//
//  ViewController.m
//  collectionViewExchange
//
//  Created by Rochester on 22/12/16.
//  Copyright © 2016年 Rochester. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
//       <#what#>
@property (nonatomic,strong) UICollectionView *collectionView;
//       <#what#>
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGes;
//       <#what#>
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
//       <#what#>
@property (nonatomic,strong) UIView *snapImageView;

//       <#what#>
@property (nonatomic,assign) CGPoint detailPoint;

//
@property (nonatomic,strong) NSMutableArray *jsonArr;
@end

@implementation ViewController
- (NSMutableArray *)jsonArr{
    if (!_jsonArr) {
        _jsonArr = [NSMutableArray array];
    }
    return _jsonArr;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(110, 44);
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView addGestureRecognizer:self.longPressGes];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}
- (UILongPressGestureRecognizer *)longPressGes{
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    }
    return _longPressGes;
}
- (void)longPressGes:(UILongPressGestureRecognizer *)longPressGes{
    // 获取当前手势所在的点
    CGPoint currentPoint = [longPressGes locationInView:longPressGes.view];
   
   
    switch (longPressGes.state) {
        case UIGestureRecognizerStateBegan:{
            self.currentIndexPath = [self.collectionView indexPathForItemAtPoint:currentPoint];
            // 从当前点获取当前的cell
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
            // 将当前cell截图
            UIView *imageView = [cell snapshotViewAfterScreenUpdates:NO];
            _snapImageView = imageView;
            imageView.center = cell.center;
            // 隐藏cell
            cell.alpha = 0.0f;
            _snapImageView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
            // 计算手指与cell之间的距离
            _detailPoint = CGPointMake(currentPoint.x - cell.frame.origin.x, currentPoint.y - cell.frame.origin.y);
            [self.collectionView addSubview:_snapImageView];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            // 设置现在截图的位置
            CGRect snapFrame = self.snapImageView.frame;
            snapFrame.origin.x = currentPoint.x - _detailPoint.x;
            snapFrame.origin.y = currentPoint.y - _detailPoint.y;
            self.snapImageView.frame = snapFrame;
            // 交换数据
            NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:currentPoint];
            if (path  && path.section == _currentIndexPath.section) {
                // 移动到后面
                NSMutableArray *oldRow = [self.jsonArr mutableCopy];
                if (path.row > self.currentIndexPath.row) {
                    for (NSInteger i = path.row; i > self.currentIndexPath.row ; i--) {
                        [oldRow exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                    }
                }else if (path.row < self.currentIndexPath.row){ // 移动到前面
                    for (NSInteger i  = path.row; i < self.currentIndexPath.row; i++) {
                        [oldRow exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                    }
                }
                
                // 更新交换后的数据
                self.jsonArr = oldRow;
                // 交换cell
                [self.collectionView moveItemAtIndexPath:_currentIndexPath toIndexPath:path];
                _currentIndexPath = path;
                // 获取到新位置的cell
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_currentIndexPath];
                cell.alpha = 0.0f;
            }
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_currentIndexPath];
            cell.alpha = 1.0f;
            [self.snapImageView removeFromSuperview];
            _currentIndexPath = nil;
        }
            
            break;
        default:
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"kk"];
    for (int i; i <= 200; i++) {
        [self.jsonArr addObject:[NSString stringWithFormat:@"%zd-----",i]];
    }
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 20;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kk" forIndexPath:indexPath];
    for (UILabel *label in cell.subviews) {
        if (label) {
            [label removeFromSuperview];
        }
    }
    UILabel *label = [[UILabel alloc] init];
    [cell addSubview:label];
    label.text = self.jsonArr[indexPath.item];
    cell.backgroundColor = [UIColor redColor];
    
    label.frame = cell.bounds;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
