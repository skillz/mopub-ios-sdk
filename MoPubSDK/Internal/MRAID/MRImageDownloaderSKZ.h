//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRImageDownloaderDelegateSKZ;

@interface MRImageDownloaderSKZ : NSObject

@property (nonatomic, assign) id<MRImageDownloaderDelegateSKZ> delegate;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableDictionary *pendingOperations;

- (id)initWithDelegate:(id<MRImageDownloaderDelegateSKZ>)delegate;
- (void)downloadImageWithURL:(NSURL *)URL;

@end

@protocol MRImageDownloaderDelegateSKZ <NSObject>

@required
- (void)downloaderDidFailToSaveImageWithURL:(NSURL *)URL error:(NSError *)error;

@end
