//
//  ImageCompressor.h
//  PNGSquash
//
//  Created by Michael Sanders on 6/15/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Foundation/Foundation.h>

@protocol ImageCompressorDelegate <NSObject>

- (void)compressedFile:(NSString *)infile toFile:(NSString *)outfile;
- (BOOL)runCompressor:(NSString *)compressor forFile:(int)fileNum;

@end

@interface ImageCompressor : NSObject
{
	NSArray *outfiles; // The files to be compressed
	NSString *outfile; // The file currently being compressed
	NSString *infile; // The file moved to the trash
	NSTask *currentTask;
	NSString *pngoutPath;

	unsigned int imageIndex, progIndex; // Index of current image/compressor
	unsigned int level; // Compression level
	unsigned int outfilesCount;
	unsigned int compressorCount; // Count of compressors being used

	id <ImageCompressorDelegate> delegate;
	SEL didEndSelector;
	id compressDelegate;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString *pngoutPath;
@property (readonly) unsigned int compressorCount;

- (void)compressFiles:(NSArray *)files
              atLevel:(unsigned int)compressLevel
       didEndSelector:(SEL)selector
			   object:(id)object;
- (NSError *)cancelCompressing;
- (NSError *)undoMoveToTrash;

@end
