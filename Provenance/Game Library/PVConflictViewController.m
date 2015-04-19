//
//  PVConflictViewController.m
//  Provenance
//
//  Created by James Addyman on 17/04/2015.
//  Copyright (c) 2015 James Addyman. All rights reserved.
//

#import "PVConflictViewController.h"
#import "PVGameImporter.h"
#import "PVEmulatorConfiguration.h"

@interface PVConflictViewController ()

@property (nonatomic, strong) PVGameImporter *gameImporter;
@property (nonatomic, strong) NSArray *conflictedFiles;

@end

@implementation PVConflictViewController

- (instancetype)initWithGameImporter:(PVGameImporter *)gameImporter
{
    if ((self = [super initWithStyle:UITableViewStylePlain]))
    {
        self.gameImporter = gameImporter;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Solve Conflicts";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    self.conflictedFiles = [self.gameImporter conflictedFiles];
}

- (void)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    return documentsDirectoryPath;
}

- (NSString *)conflictsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    return [documentsDirectoryPath stringByAppendingPathComponent:@"conflicts"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conflictedFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSString *file = self.conflictedFiles[[indexPath row]];
    NSString *name = [[file lastPathComponent] stringByReplacingOccurrencesOfString:[@"." stringByAppendingString:[file pathExtension]] withString:@""];
    
    [[cell textLabel] setText:name];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    NSString *path = self.conflictedFiles[[indexPath row]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose a System"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *systemID in [[PVEmulatorConfiguration sharedInstance] availableSystemIdentifiers])
    {
        NSArray *supportedExtensions = [[PVEmulatorConfiguration sharedInstance] fileExtensionsForSystemIdentifier:systemID];
        if ([supportedExtensions containsObject:[path pathExtension]])
        {
            NSString *name = [[PVEmulatorConfiguration sharedInstance] shortNameForSystemIdentifier:systemID];
            [alertController addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.gameImporter resolveConflictsWithSolutions:@{path: systemID}];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                self.conflictedFiles = [self.gameImporter conflictedFiles];
                [self.tableView endUpdates];
            }]];
        }
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:alertController animated:YES completion:NULL];
}

@end