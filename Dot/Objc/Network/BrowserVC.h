#import <UIKit/UIKit.h>
#import <Foundation/NSNetServices.h>

@class BrowserVC;

@protocol BrowserVCDelegate <NSObject>
@required
// This method will be invoked when the user selects one of the service instances from the list.
// The ref parameter will be the selected (already resolved) instance or nil if the user taps the 'Cancel' button (if shown).
- (void) browserVC:(BrowserVC*)bvc didResolveInstance:(NSNetService*)ref;
@end

@interface BrowserVC : UITableViewController {

@private
	id<BrowserVCDelegate> __weak _delegate;
	NSString* _searchingForServicesString;
	NSString* _ownName;
	NSNetService* _ownEntry;
	BOOL _showDisclosureIndicators;
	NSMutableArray* _services;
	NSNetServiceBrowser* _netServiceBrowser;
	NSNetService* _currentResolve;
	NSTimer* _timer;
	BOOL _needsActivityIndicator;
	BOOL _initialWaitOver;
}

@property (nonatomic, weak) id<BrowserVCDelegate> delegate;
@property (nonatomic, copy) NSString* searchingForServicesString;
@property (nonatomic, copy) NSString* ownName;

- (id)initWithTitle:(NSString*)title showDisclosureIndicators:(BOOL)showDisclosureIndicators showCancelButton:(BOOL)showCancelButton;
- (BOOL)searchForServicesOfType:(NSString*)type inDomain:(NSString*)domain;

@end
