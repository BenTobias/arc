//
//  AppDelegate.m
//  arc
//
//  Created by Yong Michael on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CodeViewController.h"
#import "LeftViewController.h"

// Necessary only if "Open in..." handling is inline here.
#import "LocalFolder.h"
#import "LocalFile.h"
#import "LocalRootFolder.h"
// End of "Open in..." imports
#import <Dropbox/Dropbox.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// Handles the case when the application launches through "Open in..."
// The file to be opened is saved by the OS into our Documents folder,
// and we are given its URL.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
                                       sourceApplication:(NSString *)sourceApplication
                                              annotation:(id)annotation
{
    // Check that this is a file URL.
    if ([url isFileURL]) {
        // Get the "Inbox" folder.
        NSURL *inboxURL = [url URLByDeletingLastPathComponent];
        NSString *inboxName = [inboxURL lastPathComponent];
        NSString *inboxPath = [inboxURL path];
        LocalFolder *inboxFolder = [[LocalFolder alloc] initWithName:inboxName
                                                                identifier:inboxPath
                                                              parent:[LocalRootFolder sharedLocalRootFolder]];

        LocalFile *receivedFile = [[LocalFile alloc] initWithName:[url lastPathComponent]
                                                             identifier:[url path]
                                                           parent:inboxFolder];
        
        // Open file
        id<MainViewControllerDelegate> mainViewController = (id<MainViewControllerDelegate>) _window.rootViewController;
        [mainViewController openIn:receivedFile];

        return YES;
    } else {
        // Pass off to DropBox for authentication.
        DBAccount *dropboxAccount = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (dropboxAccount) {
            // Set up the DropBox Filesystem.
            DBFilesystem *dropboxFilesystem = [[DBFilesystem alloc] initWithAccount:dropboxAccount];
            [DBFilesystem setSharedFilesystem:dropboxFilesystem];
        }
    }
    return NO;
}
- (void)addFileToFileManager:(NSFileManager*)fm name:(NSString*)name docURL:(NSURL*)docURL {
    NSURL *sampleFile = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    NSURL *newFile = [NSURL URLWithString:name relativeToURL:docURL];
    if (![fm fileExistsAtPath:[newFile path]]) {
        [fm copyItemAtURL:sampleFile toURL:newFile error:nil];
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Check if we have our appState property list.
    // If not, move it into the Documents library.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[LocalRootFolder sharedLocalRootFolder] identifier];
    NSString *appStatePath = [documentsPath stringByAppendingPathComponent:FILE_APP_STATE];
    if (![fileManager fileExistsAtPath:appStatePath]) {
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:FILE_APP_STATE withExtension:nil];
        NSURL *targetURL = [NSURL fileURLWithPath:appStatePath];
    
        NSError *error;
        [fileManager copyItemAtURL:plistURL toURL:targetURL error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        
        // This is the first time the app has launched.
        // Copy our source code into the Documents folder.
        NSURL *documentsURL = [NSURL fileURLWithPath:documentsPath];
        NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
        
        NSURL *controllersFolder = [bundleURL URLByAppendingPathComponent:@"Controllers" isDirectory:YES];
        NSURL *modelFolder = [bundleURL URLByAppendingPathComponent:@"Model" isDirectory:YES];
        NSURL *pluginFolder = [bundleURL URLByAppendingPathComponent:@"Plugin" isDirectory:YES];
        NSURL *viewFolder = [bundleURL URLByAppendingPathComponent:@"View" isDirectory:YES];

        NSURL *arcFolder = [documentsURL URLByAppendingPathComponent:@"(arc) Code" isDirectory:YES];
        NSURL *controllerTarget = [arcFolder URLByAppendingPathComponent:@"Controllers" isDirectory:YES];
        NSURL *modelTarget = [arcFolder URLByAppendingPathComponent:@"Model" isDirectory:YES];
        NSURL *pluginTarget = [arcFolder URLByAppendingPathComponent:@"Plugins" isDirectory:YES];
        NSURL *viewTarget = [arcFolder URLByAppendingPathComponent:@"View" isDirectory:YES];
        
        [fileManager createDirectoryAtURL:arcFolder withIntermediateDirectories:YES attributes:nil error:nil];
        
        [fileManager copyItemAtURL:controllersFolder toURL:controllerTarget error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        [fileManager copyItemAtURL:modelFolder toURL:modelTarget error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        [fileManager copyItemAtURL:pluginFolder toURL:pluginTarget error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        [fileManager copyItemAtURL:viewFolder toURL:viewTarget error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        
        
        // Jerome: Temporary code to move support files into the Documents folder.
        [self addFileToFileManager:fileManager name:@"twist.py" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"GameObject.h" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"home.html" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"nav_gmaps_sample.js" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"arc.md" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"base.rb" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"RequestBuilder.hs" docURL:documentsURL];
        [self addFileToFileManager:fileManager name:@"filter_routes.clj" docURL:documentsURL];
        // End of temporary code.
    }
    
    // Create the DropBox account manager.
    NSString *cloudPath = [[NSBundle mainBundle] pathForResource:@"cloudKeys" ofType:@"plist"];
    NSDictionary *cloudKeys = [NSDictionary dictionaryWithContentsOfFile:cloudPath];
    NSDictionary *dropboxCredentials = [cloudKeys valueForKey:@"Dropbox"];
    DBAccountManager* dbAccountManager =
    [[DBAccountManager alloc] initWithAppKey:[dropboxCredentials valueForKey:@"Key"]
                                      secret:[dropboxCredentials valueForKey:@"Secret"]];
    [DBAccountManager setSharedManager:dbAccountManager];
    DBAccount *dbAccount = dbAccountManager.linkedAccount;
    
    if (dbAccount) {
        // We already have an account, and can set up the DropBox file system.
        DBFilesystem *dbFilesystem = [[DBFilesystem alloc] initWithAccount:dbAccount];
        [DBFilesystem setSharedFilesystem:dbFilesystem];
    }
    
    // UI theming
    [UI exec];

    // Create Window Object
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create MainViewController
    MainViewController *mainViewController = [[MainViewController alloc] init];

    // Assign SubViewControllers
    mainViewController.masterView = [[UIView alloc] init];
    mainViewController.detailView = [[UIView alloc] init];
    
    // Set ArcSplitViewController Delegate
    mainViewController.delegate = mainViewController;

    // Set MainViewController as RootViewController
    [self.window setRootViewController:mainViewController];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"arc" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"arc.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
