//
//  ComentarViewController.m
//  TaxiCDMX
//
//  Created by Carlos Castellanos on 05/03/14.
//  Copyright (c) 2014 Carlos Castellanos. All rights reserved.
//

#import "ComentarViewController.h"
#import "InitViewController.h"
#import "AppDelegate.h"
@interface ComentarViewController ()

@end

@implementation ComentarViewController
{
    NSMutableArray *tableData;
    BOOL flag;
    AppDelegate * delegate;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad
{
    flag=FALSE;
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapScroll];
    delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self obtenerComentarios];
  
    [super viewDidLoad];

}
-(IBAction)reload:(id)sender
{
    [self obtenerComentarios];
}


-(void)obtenerComentarios{
    NSString *urlString = [NSString stringWithFormat:@"http://placas-taxi.herokuapp.com/placas/%@.json",delegate.placa];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if ([data length] >0  )
        {
            
            NSString *dato=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableString * miCadena = [NSMutableString stringWithString: dato];
            NSData *data1 = [miCadena dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *comentarios=[NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:nil];
            tableData=[comentarios objectForKey:@"comentarios"];
            [_tabla reloadData];
            
            
            
        }});

}
-(IBAction)comentar:(id)sender{

    if(flag){
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Gracias" message:@"Ya has comentado este taxi " delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];//success
        }
    else{
      
       
        if ([_comentario.text isEqualToString:@""]) {
            NSLog(@"texto vacio");
        
        }
        else {
             flag=TRUE;
            
            NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://placas-taxi.herokuapp.com/comentarios.json"]];
            [request1 setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            [request1 setHTTPBody:[[NSString stringWithFormat:@"comentario[placa]=%@&comentario[coment]=%@&comentario[usuario]=1&comentario[buen_comentario]=1",delegate.placa,_comentario.text] dataUsingEncoding:NSUTF8StringEncoding]];
            [request1 setHTTPMethod:@"POST"];
            NSError *error = nil; NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&response error:&error];
            // NSDictionary *myDictionary = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (error) {
                NSLog(@"Error:%@", error.localizedDescription);
            }
            else {
                UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Gracias" message:@"Tu comentario se ah publicado" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alert show];//success
                [self obtenerComentarios];
            }

        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[tableData objectAtIndex:indexPath.row]objectForKey:@"coment"];
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) tapped
{
     [self.view endEditing:YES];
}

-(IBAction)regresar:(id)sender
{
    InitViewController *pedir = [[self storyboard] instantiateViewControllerWithIdentifier:@"init"];
    
    pedir.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:pedir animated:YES completion:NULL];

}
@end
