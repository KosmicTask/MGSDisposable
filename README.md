##MGSDisposable

A Cocoa category to assist with resource disposal.

In a GC environment an object cannot reliably cleanup its ivar object resources in `-finalize` as the ivar objects and `self` may get collected in the same collection cycle. When this occurs an ivar may get finalised before `self` which can lead to object resurrection errors.

The solution to the above is normally to define a `-dispose` method that we call prior to finalisation. This has to be done manually. In simple scenarios this works well but in more complex situations (where multiple object references may be held) it can be become difficult to anticipate when to call `-dispose`.

MGSDisposable is a category that adds a reference counting mechanism to any class. The design and usage is similar to that employed when using Cocoa manual retain-release memory management. The use of a category means that the reference counting mechanism can be incorporated into any class and does not interpose in the class hierarchy.

In order to avoid collisions with other methods in the NSObject namespace all category methods use an `mgs` prefix.

##Usage

To mark the class as disposable when required call `-mgsMakeDisposable `. This will normally be during initialisation. When `-mgsMakeDisposable` returns the object will have a disposal count of 1. Retain and release methods are used to increment and decrement the disposal count. When the disposal count reaches 0 the `-mgsDispose` message is sent and our object disposes of its resources.

	#import "NSObject+MGSDisposable.h"
	
	@implementation MyClass

	- (void)init
	{
		self = [super init];
		if (self) {
			[self mgsMakeDisposable];
			
			// assign ivars
			_path = @"~\workfile.tmp";
			_ptr = malloc(1000);

			// create work file
			[[NSFileManager defaultManager] createFileAtPath:_path contents:nil attributes:nil];
		}

		return self;
	}
	
	- (void)mgsDispose
	{
		 // check if already disposed
    	if ([self isMgsDisposedWithLogIfTrue]) {
			return;
		}

		// dispose of our work file
		[[NSFileManager defaultManager] removeItemAtPath:_path error:nil];

		// we need to call super
		[super mgsDispose];
	}

	- (void)finalize
	{
		// We can free our manually allocated memory block here.
		// Attempting to delete our work file here would sometimes 
		// likely result in a resurrection error
		free(_ptr);
	}

	@end

The class above could be utilised like so:

	#import "NSObject+MGSDisposable.h"

	// define object - disposal count will be 1.
	// our work file has been created.
	MyClass *mine = [MyClass new];

	// create another reference.
	// disposal count is 2.
	MyClass *mineToo = mine;
	[mineToo mgsRetainDisposable];

	// discard the first reference.
	// disposal count is 1.
	[mine mgsReleaseDisposable];
	mine = nil;

	// discard the second reference.
	// disposal count drops to 0, -mgsDispose is sent 
	// and work file is removed.
	[mineToo mgsReleaseDisposable];

	// the MyClass object will become collectable and
	// -finalize will be sent at some time.
	mineToo = nil;

##Licence

Licence is MIT


