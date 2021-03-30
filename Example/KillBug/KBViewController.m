//
//  KBViewController.m
//  KillBug
//
//  Created by tliens on 03/29/2021.
//  Copyright (c) 2021 tliens. All rights reserved.
//

#import "KBViewController.h"

@interface KBViewControllerA:UIViewController<UITableViewDelegate,UITableViewDataSource>

@end

@interface KBViewController ()

@end

@implementation KBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 430, 100, 100)];
    [btn1 setTitle:@"小明" forState:(UIControlStateNormal)];
    btn1.backgroundColor  = [UIColor redColor];
    [self.view addSubview:btn1];
    
    [btn1 addTarget:self action:@selector(btn1Action:) forControlEvents:(UIControlEventTouchUpInside)];
}
- (void) btn1Action:(UIButton*)btn{
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAAction:(id)sender {
    
}
- (IBAction)manualCrash:(id)sender {
    NSArray *arr = @[@0];
    arr[1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    KBViewControllerA *vc = [[KBViewControllerA alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:true completion:nil];
}
@end


@implementation KBViewControllerA

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor yellowColor];
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 300, 400)];
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableview];
    
    tableview.delegate = self;
    tableview.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    c.textLabel.text = @"😁";
    c.backgroundColor = [UIColor blueColor];
    return c;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
