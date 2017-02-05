//
//  ZipArchive.mm
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"



@interface ZipArchive (Private)

- (void)OutputErrorMessage:(NSString*) msg;
- (BOOL)OverWrite:(NSString*) file;
-(NSDate*) Date1980;
@end



@implementation ZipArchive
@synthesize delegate = _delegate;

- (id)init
{
	if( self=[super init] )
	{
		_zipFile = NULL ;
	}
	return self;
}
//arc
/*
- (void)dealloc
{
	[self CloseZipFile2];
	[super dealloc];
}
*/
- (BOOL)CreateZipFile2:(NSString*) zipFile
{
	_zipFile = zipOpen( (const char*)[zipFile UTF8String], 0 );
	if( !_zipFile ) 
		return NO;
	return YES;
}

- (BOOL)CreateZipFile2:(NSString*) zipFile Password:(NSString*) password {
    
	_password = password;
	return [self CreateZipFile2:zipFile];
}
- (BOOL)addDataToZip:(NSData*)data date:(NSDate*)date newname:(NSString*) newname {

	if (!_zipFile)
		return NO;
    if (!data)
        return NO;
    
    zip_fileinfo zipInfo = {0};
    if (date) {
        //	tm_zip filetime;       
        // some application does use dosDate, but tmz_date instead
		//	zipInfo.dosDate = [fileDate timeIntervalSinceDate:[self Date1980] ];
        NSCalendar* currCalendar = [NSCalendar currentCalendar];
        uint flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | 
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ;
        NSDateComponents* dc = [currCalendar components:flags fromDate:date];
        zipInfo.tmz_date.tm_sec = [dc second];
        zipInfo.tmz_date.tm_min = [dc minute];
        zipInfo.tmz_date.tm_hour = [dc hour];
        zipInfo.tmz_date.tm_mday = [dc day];
        zipInfo.tmz_date.tm_mon = [dc month] - 1;
        zipInfo.tmz_date.tm_year = [dc year];
    }
    
	int ret;
    if ([_password length] == 0) {
		
        ret = zipOpenNewFileInZip( _zipFile,
								  (const char*) [newname UTF8String],
								  &zipInfo,
								  NULL,0,
								  NULL,0,
								  NULL,//comment
								  Z_DEFLATED,
								  Z_DEFAULT_COMPRESSION );
	}
	else {
        
		uLong crcValue = crc32( 0L,NULL, 0L );
		crcValue = crc32( crcValue, (const Bytef*)[data bytes], [data length] );
		ret = zipOpenNewFileInZip3( _zipFile,
                                   (const char*) [newname UTF8String],
                                   &zipInfo,
                                   NULL,0,
                                   NULL,0,
                                   NULL,//comment
                                   Z_DEFLATED,
                                   Z_DEFAULT_COMPRESSION,
                                   0,
                                   15,
                                   8,
                                   Z_DEFAULT_STRATEGY,
                                   [_password cStringUsingEncoding:NSASCIIStringEncoding],
                                   crcValue );
	}
	if (ret!=Z_OK )
		return NO;

	unsigned int dataLen = [data length];
	ret = zipWriteInFileInZip( _zipFile, (const void*)[data bytes], dataLen);
	if (ret!=Z_OK) 
		return NO;

	ret = zipCloseFileInZip( _zipFile );
	if (ret!=Z_OK) 
		return NO;
    
	return YES;
}
- (BOOL)addFileToZip:(NSString*)file newname:(NSString*) newname {

	time_t current;
	time( &current );
	
	NSDate* date;
	NSDictionary* attr = [[NSFileManager defaultManager] fileAttributesAtPath:file traverseLink:YES];
	if( attr )
		date = (NSDate*)[attr objectForKey:NSFileModificationDate];
    else 
        date = [NSDate date];

	NSData* data = [ NSData dataWithContentsOfFile:file];
    
	int ret = [self addDataToZip:data date:date newname:newname];
    return ret;
}

- (BOOL)CloseZipFile2 {
    
	_password = nil;
	if( _zipFile==NULL )
		return NO;
	BOOL ret =  zipClose( _zipFile,NULL )==Z_OK?YES:NO;
	_zipFile = NULL;
	return ret;
}

- (BOOL)UnzipOpenFile:(NSString*) zipFile {
    
	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile ) {
        
		unz_global_info  globalInfo = {0};
		if( unzGetGlobalInfo(_unzFile, &globalInfo )==UNZ_OK ) {
            
			//NSLog([NSString stringWithFormat:@"%d entries in the zip file",globalInfo.number_entry] );
		}
	}
	return _unzFile!=NULL;
}

- (BOOL)UnzipOpenFile:(NSString*) zipFile Password:(NSString*) password
{
	_password = password;
	return [self UnzipOpenFile:zipFile];
}

- (BOOL)writeUnzippedFileTo:(NSString*)fullPath fileInfo:(unz_file_info&) fileInfo {
    
    unsigned char buffer[4096] = {0};
    FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
    while( fp )
    {
        int read=unzReadCurrentFile(_unzFile, buffer, 4096);
        if( read > 0 )
        {
            fwrite(buffer, read, 1, fp );
        }
        else if( read<0 )
        {
            [self OutputErrorMessage:@"Failed to reading zip file"];
            break;
        }
        else 
            break;				
    }
    if( fp )
    {
        fclose( fp );
        // set the orignal datetime property
        NSDate* orgDate = nil;
        
        //{{ thanks to brad.eaton for the solution
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        
        dc.second = fileInfo.tmu_date.tm_sec;
        dc.minute = fileInfo.tmu_date.tm_min;
        dc.hour = fileInfo.tmu_date.tm_hour;
        dc.day = fileInfo.tmu_date.tm_mday;
        dc.month = fileInfo.tmu_date.tm_mon+1;
        dc.year = fileInfo.tmu_date.tm_year;
        
        NSCalendar *gregorian = [[NSCalendar alloc] 
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        
        orgDate = [gregorian dateFromComponents:dc] ;
        //}}
        
        
        NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
        if( attr )
        {
            //		[attr  setValue:orgDate forKey:NSFileCreationDate];
            if( ![[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPath error:nil] ) {
                
                // cann't set attributes 
                NSLog(@"Failed to set attributes");
                return NO;
            }				
        }
    }
    return YES;
}
- (BOOL)UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite {
    
	BOOL success = YES;
	int ret = unzGoToFirstFile( _unzFile );
    
	NSFileManager* fman = [NSFileManager defaultManager];
	if( ret!=UNZ_OK ) {
		[self OutputErrorMessage:@"Failed"];
	}
	
	for (;ret==UNZ_OK; ret = unzGoToNextFile(_unzFile)) {
        
		if( [_password length]==0 )
			ret = unzOpenCurrentFile( _unzFile );
		else
			ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
		if( ret!=UNZ_OK ) {
            
			[self OutputErrorMessage:@"Error occurs"];
			success = NO;
			break;
		}
		// reading data and write to file

		unz_file_info	fileInfo ={0};
		ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
		if( ret!=UNZ_OK ) {
            
			[self OutputErrorMessage:@"Error occurs while getting file info"];
			success = NO;
			unzCloseCurrentFile( _unzFile );
			break;
		}
		char* filename = (char*) malloc( fileInfo.size_filename +1 );
		unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
		filename[fileInfo.size_filename] = '\0';
		
		// check if it contains directory
		NSString * strPath = [NSString  stringWithCString:filename];
		BOOL isDirectory = NO;
		if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
			isDirectory = YES;

		if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound ) {
            // contains a path
			strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		}
		NSString* fullPath = [path stringByAppendingPathComponent:strPath];
		
		if( isDirectory )
			[fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
		else
			[fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
		if( [fman fileExistsAtPath:fullPath] && !isDirectory && !overwrite ) {
            
			if( ![self OverWrite:fullPath] ) {
                
				unzCloseCurrentFile( _unzFile );
				ret = unzGoToNextFile( _unzFile );
				continue;
			}
		}
        [self writeUnzippedFileTo:fullPath fileInfo:fileInfo];
        free( filename );
        unzCloseCurrentFile( _unzFile );
    } 
    return success;
}
- (NSString *)stringFromFile:(NSString *)findExt foundName:(NSString**)foundName {
    
    NSData *data = [self dataFromFile:findExt foundName:foundName];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

- (NSData*)dataFromFile:(NSString *)findName foundName:(NSString**)foundName {
    
	int ret = unzGoToFirstFile( _unzFile );
    
	if( ret!=UNZ_OK ) {
		[self OutputErrorMessage:@"Failed"];
	}
	
	for (;ret==UNZ_OK; ret = unzGoToNextFile(_unzFile)) {
        
		if( [_password length]==0 )
			ret = unzOpenCurrentFile( _unzFile );
		else
			ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
		if (ret!=UNZ_OK ) {
            
			[self OutputErrorMessage:@"Error occurs"];
			 return nil;
		}
		unz_file_info fileInfo ={0};
		ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
		if( ret!=UNZ_OK ) {
            
			[self OutputErrorMessage:@"Error occurs while getting file info"];
			unzCloseCurrentFile( _unzFile );
			return nil;
		}
		char* filename = (char*) malloc( fileInfo.size_filename +1 );
		unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename, NULL, 0, NULL, 0);
		filename[fileInfo.size_filename] = '\0';
        NSString *foundPath = [NSString stringWithUTF8String:filename];
        
		if ([foundPath isEqualToString:findName] ||
            [foundPath hasSuffix:findName]) { //TODO: replace extension search with wildcard
            
            if (foundName) {
                
                NSArray *pathComponents = [[foundPath stringByDeletingPathExtension]pathComponents];
                *foundName = [pathComponents lastObject];
             }
            char *buffer = (char*)malloc(fileInfo.uncompressed_size);
            int result = unzReadCurrentFile(_unzFile, buffer, fileInfo.uncompressed_size);
            NSData*data = [NSData dataWithBytesNoCopy:buffer length:fileInfo.uncompressed_size];
            unzCloseCurrentFile( _unzFile );
            free(filename);
            return data;
        }
        if (filename) {
            free(filename);
            filename = 0;
        }
        unzCloseCurrentFile( _unzFile );
    } 
    return nil;
}

- (BOOL)UnzipCloseFile
{
	_password = nil;
	if( _unzFile )
		return unzClose( _unzFile )==UNZ_OK;
	return YES;
}

#pragma mark wrapper for delegate
- (void)OutputErrorMessage:(NSString*) msg
{
	if( _delegate && [_delegate respondsToSelector:@selector(ErrorMessage)] )
		[_delegate ErrorMessage:msg];
}

- (BOOL)OverWrite:(NSString*) file
{
	if( _delegate && [_delegate respondsToSelector:@selector(OverWriteOperation)] )
		return [_delegate OverWriteOperation:file];
	return YES;
}

#pragma mark get NSDate object for 1980-01-01
-(NSDate*) Date1980
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:1];
	[comps setMonth:1];
	[comps setYear:1980];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	
	return date;
}


@end


