//
//  ViewController.m
//  Demo6
//
//  Created by vfa on 8/17/22.
//

#import "ViewController.h"
NSString *const kBottomBoundary = @"bottomBoundary";
@interface ViewController ()
@property (nonatomic,strong) UIView *squareView;
@property (nonatomic,strong) UIView *squareView1;
@property (nonatomic,strong) UIView *squareView2;
@property (nonatomic,strong) UIView *squareView3;
@property (nonatomic,strong) UIView *squareView4;
@property (nonatomic,strong) UIView *squareView5;
@property (nonatomic,strong) NSMutableArray *squareViews;
@property (nonatomic,strong) UIDynamicAnimator * animator;
@property (nonatomic,strong) UIPushBehavior *pushBehavior;
@property (nonatomic,strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic,strong) UISnapBehavior *snapBehavior;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    NSString *strIdentifier = (NSString *)identifier;
    if([strIdentifier isEqualToString:kBottomBoundary]){
    
        [UIView animateWithDuration:1 animations:^{
            UIView *view = (UIView *)item;
            
            view.backgroundColor = [UIColor redColor];
            view.alpha = 0;
            view.transform = CGAffineTransformMakeScale(2, 2);
        } completion:^(BOOL finished) {
            UIView *view = (UIView *)item;
            [behavior removeItem:item];
            [view removeFromSuperview];
        }];
    }

}
- (void)viewDidAppear:(BOOL)animated{
    self.squareView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -25, 0, 50, 50)];
    
    self.squareView.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:self.squareView];
    
    //create animator and gravity
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.squareView]];
    
    [self.animator addBehavior: gravity];
    
    self.squareViews = [[NSMutableArray alloc] initWithCapacity:2];
    NSArray *colors = @[[UIColor redColor],[UIColor greenColor]];
    
    CGPoint currentCenterPoint = self.view.center;
    CGSize eachViewSize = CGSizeMake(50, 50);
    
    for (NSUInteger i=0; i<2; i++) {
        UIView *newView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, eachViewSize.width, eachViewSize.height)];
        newView.backgroundColor = colors[i];
        newView.center = currentCenterPoint;
        currentCenterPoint.y += eachViewSize.height +10;
        
        [self.view addSubview:newView];
        
        [self.squareViews addObject:newView];
    }
        //collision between 2 square view
    UIGravityBehavior *gravity2 = [[UIGravityBehavior alloc] initWithItems:self.squareViews];
    
    [self.animator addBehavior:gravity2];
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:self.squareViews];
    
    [collision addBoundaryWithIdentifier:kBottomBoundary fromPoint:CGPointMake(0, self.view.bounds.size.height-100) toPoint:CGPointMake(self.view.frame.size.width, self.view.bounds.size.height-100)];
    
    collision.collisionDelegate = self;
    
    [self.animator addBehavior:collision];
    
    //push behavior
    [self createGestureRecognizer];
    self.squareView1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.squareView.frame.size.height + 20, 50, 50)];
    
    self.squareView1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.squareView1];
    
    UICollisionBehavior *collision1 = [[UICollisionBehavior alloc] initWithItems:@[self.squareView1]];
    
    collision1.translatesReferenceBoundsIntoBoundary = YES;
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.squareView1] mode:UIPushBehaviorModeContinuous];
    
    [self.animator addBehavior:collision1];
    [self.animator addBehavior:self.pushBehavior];
    
    //attach multiple dynamic items to each other
    [self createPanGestureRecognizer];
    self.squareView2 = [[UIView alloc] initWithFrame:CGRectMake(20, self.squareView1.frame.origin.y + 120, 80, 80)];
    
    self.squareView2.backgroundColor = [UIColor grayColor];
    
    self.squareView3 = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 20, 20)];
    
    self.squareView3.backgroundColor = [UIColor brownColor];
    
    self.squareView4 = [[UIView alloc] initWithFrame:CGRectMake(20, self.squareView1.frame.origin.y + 70, 20, 20)];
    
    self.squareView4.backgroundColor = [UIColor redColor];
    
    [self.squareView2 addSubview:self.squareView3];
    [self.view addSubview:self.squareView2];
    [self.view addSubview:self.squareView4];
    
    UICollisionBehavior *collision2 = [[UICollisionBehavior alloc] initWithItems:@[self.squareView2]];
    
    collision2.translatesReferenceBoundsIntoBoundary = YES;
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.squareView2 offsetFromCenter:UIOffsetMake(self.squareView3.frame.origin.x, self.squareView3.frame.origin.y) attachedToAnchor:self.squareView4.center];
    
    [self.animator addBehavior:collision2];
    [self.animator addBehavior:self.attachmentBehavior];
    
    
    //snap effect
    
    [self createSnapGestureRecgnizer];
    self.squareView5 = [[UIView alloc] initWithFrame:CGRectMake(0, self.squareView2.frame.origin.y+120, 80, 80)];
    
    self.squareView5.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.squareView5];
    
    UICollisionBehavior *collision3 = [[UICollisionBehavior alloc] initWithItems:@[self.squareView5]];
    
    collision3.translatesReferenceBoundsIntoBoundary = YES;
    
    [self.animator addBehavior:collision3];
    
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.squareView5 snapToPoint:self.squareView5.center];
    
    self.snapBehavior.damping =0.5f;
    
    [self.animator addBehavior:self.snapBehavior];
    
    //assign characteristics to dynamic effect
    
    
    UIView *topView = [self newViewWithCenter:CGPointMake(self.view.frame.size.width-50, 0) backgroundColor:[UIColor orangeColor]];
    
    UIView *bottomView = [self newViewWithCenter:CGPointMake(self.view.frame.size.width-50, 50) backgroundColor:[UIColor purpleColor]];
    
    [self.view addSubview:topView];
    [self.view addSubview:bottomView];
    
    UIGravityBehavior *gravity3 = [[UIGravityBehavior alloc] initWithItems:@[topView,bottomView]];
    
    [self.animator addBehavior:gravity3];
    
    UICollisionBehavior *collision4 = [[UICollisionBehavior alloc] initWithItems:@[topView,bottomView]];
    
    collision4.translatesReferenceBoundsIntoBoundary = YES;
    
    [self.animator addBehavior:collision4];
    
    UIDynamicItemBehavior *moreElasticItem = [[UIDynamicItemBehavior alloc] initWithItems:@[bottomView]];
    
    moreElasticItem.elasticity = 1.0f;
    
    UIDynamicItemBehavior *lessElasticItem = [[UIDynamicItemBehavior alloc] initWithItems:@[topView]];
    
    lessElasticItem.elasticity = 0.5f;
    
    [self.animator addBehavior:moreElasticItem];
    [self.animator addBehavior:lessElasticItem];
}
- (UIView *) newViewWithCenter:(CGPoint)paramCenter backgroundColor:(UIColor *)paramBackgroundColor{
    UIView *newView =
    [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    newView.backgroundColor = paramBackgroundColor;
    newView.center = paramCenter;
    return newView;
}
- (void) createGestureRecognizer{
    UILongPressGestureRecognizer *longPressGestureRecogizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.view addGestureRecognizer: longPressGestureRecogizer];
}

-(void)handleLongPress:(UITapGestureRecognizer *)paramPress{
    
    CGPoint tapPoint = [paramPress locationInView:self.view];
    CGPoint squareView1CenterPoint = self.squareView1.center;
    CGFloat deltaX = tapPoint.x - squareView1CenterPoint.x;
    CGFloat deltaY = tapPoint.y - squareView1CenterPoint.y;
    CGFloat angle = atan2(deltaX,deltaY);
    
    [self.pushBehavior setAngle:angle];
    
    CGFloat distanceBetweenPoints = sqrt(pow(tapPoint.x - squareView1CenterPoint.x,2)+pow(tapPoint.y-squareView1CenterPoint.y,2));
    
    [self.pushBehavior setMagnitude:distanceBetweenPoints/200];
}

-(void) createPanGestureRecognizer{
    
    UIPanGestureRecognizer *panGestureRecogizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    
    [self.view addGestureRecognizer: panGestureRecogizer];
}
-(void)handlePan:(UITapGestureRecognizer *)paramPan{
    
    CGPoint tapPoint = [paramPan locationInView:self.view];
    [self.attachmentBehavior setAnchorPoint:tapPoint];
    self.squareView4.center = tapPoint;
}
-(void) createSnapGestureRecgnizer{
    UITapGestureRecognizer *tapGestureRecogizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapSnap:)];
    
    [self.view addGestureRecognizer: tapGestureRecogizer];
    
}
-(void) handleTapSnap: (UITapGestureRecognizer *)paramTap{
    CGPoint tapPoint =[paramTap locationInView:self.view];
    
    if(self.snapBehavior != nil){
        [self.animator removeBehavior:self.snapBehavior];
    
    }
    
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.squareView5 snapToPoint:tapPoint];
    
    self.snapBehavior.damping = 0.5f;
    
    [self.animator addBehavior:self.snapBehavior];
}

@end
