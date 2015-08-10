#ifdef __cplusplus
extern "C" {
#endif
    
#include <stdio.h>
#include <time.h>
    // kannuuAPI.h : Defines all items global to the application
    //
    
#ifndef DKANNUUAPIH
#define DKANNUUAPIH
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Utility constants
    ////////////////////////////////////////////////////////////////////////////////////////
#define DTrue 1
#define DFalse 0
#define DMaxSourceTextLineSize 512      // The maxmimum length of a source file line
#define DSubnodeStart 0xA0A05050        // Special int used to indicate start of a subnode on the fileindex
    
    typedef unsigned char TKBool;	// To be used for boolean variables
    typedef unsigned char TByte;	// To be used instead of char so not confused with a character
    typedef unsigned int DFileLocation;
    
#ifdef _UNICODE
#ifndef DUnicode
#define DUnicode
#endif
#endif
    
#ifdef DUnicode
    ////////////////////////////////////////////////////////////////////////////////////////
    // Unicode defines
    ////////////////////////////////////////////////////////////////////////////////////////
#ifdef DWin32
#include <tchar.h>
#else
#include <wchar.h>
#endif
    
    typedef wchar_t 	TChar;
    typedef wchar_t 	TUChar;
#define EMPTYSTR 	L""
    
#define DString(s)	L##s
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // UNICODE Utility Functions
    ////////////////////////////////////////////////////////////////////////////////////////
    
    // Copy a multi-byte character string in char* to Unicode TChar string
    extern size_t FMBCSToTChar_CharsNeeded (char* aSrc);
    extern int FMBCSToTChar_Copy (TChar* aDest, char* aSrc, size_t aMaxChars);
    extern int FMBCSToTChar_AllocAndCopy (TChar** aDest, char* aSrc);
    
    // Copy a Unicode TChar string to multi-byte character string in char*
    extern size_t FTCharToMBCS_CharsNeeded (TChar* aSrc);
    extern int FTCharToMBCS_Copy (char* aDest, TChar* aSrc, size_t aMaxChars);
    extern int FTCharToMBCS_AllocAndCopy (char** aDest, TChar* aSrc);
    
#else
#include <string.h>
    
    typedef char TChar;
    typedef unsigned char TUChar;
#define EMPTYSTR 	""
    
#define DString(s)	s
    
#endif
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Prototype Struct Declarations
    ////////////////////////////////////////////////////////////////////////////////////////
    typedef struct SIndex SIndex;
    typedef struct SFileIndex SFileIndex;
    typedef struct SMemIndex SMemIndex;
    typedef struct SMapNode SMapNode;
    typedef struct SMapIndex SMapIndex;
    
    ////////////////////////////////////////////////////////////////////////////////////////
    //// FileIndex specific definitions
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //// The modes in which the file index can be opened
    enum KFileMode
    {
        KFileModeCreate = 0,    // Create a new file index (delete the existing one if it exists)
        KFileModeUpdate,                // Open the file index for update
        KFileModeRead                   // Open the file index for reading and lookup (no modifications)
    };
    
    // Subnode types (bits values to be stored in type byte associated with each file node)
    enum ESubnodeType
    {
        KSubnodeTypeNewField = 1,// This subnode starts a new field (1) or is an internal subnode which is the continuation of a string (0)
        KSubnodeTypeEndOfField = 2,	// This subnode is the end of the field (selection)
        // (can be ANDed with other values, ie. can be Internal and End or NewField and End)
        KSubnodeTypeData = 4,	// This subnode holds the data for the string ending here
        KSubnodeTypeEndOfSubnodes = 8,	// This the end of the subnodes for the node (Used in file records)
        KSubnodeTypeUnknown = 16,	// Subnode doesn't know what it is yet
        KSubnodeTypePlaceholder = 32,	// Subnode exists as a stub which acts like a branch
        KSubnodeTypeDataCopy = 64   // Only for data subnodes and indicates that this data is a copy of another subnode
    };
    
    // File Subnode definition commonly used across index types
    typedef struct SFileSubnode
    {
        unsigned int 		iPriority;
        unsigned int 		iMaxPriority;
        unsigned int 		iBranchCount;
        TChar* 				iOptionStr;
        TChar*              iSecondStr;
        DFileLocation 		iLocation;		// Location in file of this subnode's record
        DFileLocation 		iNode;
        DFileLocation 		iParent;
        DFileLocation       iDataLoc;
        unsigned int        iDataID;
        enum ESubnodeType 	iType;
    } SFileSubnode;
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // License Validation
    //int FValidateLicense (const char *aPathToFile);
    int FValidateLicense(const char *path_to_file, const char* username);
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // class/struct SIndexState - holds set of information needed to support FIndex
    ////////////////////////////////////////////////////////////////////////////////////////
    typedef struct SIndexState
    {
        unsigned int    lenOptions;  // amount allocated for the array
        unsigned int 	iNumOptions;
        unsigned int    lenSubs;     // amount allocated for the array
        unsigned int 	iNumSubs;
        DFileLocation   iCurrentMenuLoc;
        
        TKBool  		iComplete;	// Location to store single byte boolean value of whether selection is complete
        TKBool  		iMore;		// Location to store single byte boolean value indicating whether there are more options for this esf
        
        TChar*  		iEsf;		// Location to store "entry so far" string
        TChar** 		iOption;	// Array of aNumOptions locations to store option strings for menu
        TChar*  		iData;		// Location to store hidden data string on completion of selection
        SFileSubnode** 	iSub;   	// Array of aNumSubs locations to store subnodes for selections
    } SIndexState;
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Index Class
    
    // Construction/Destruction
    /*
     int FIndex_New (SIndex** aIndex, SMemIndex* aMemIndex, SFileIndex* aFileIndex);
     int FIndex_Free (SIndex** aIndex);
     int FIndex_Initialise (SIndex* aIndex, SMemIndex* aMemIndex, SFileIndex* aFileIndex);
     int FIndex_Clear (SIndex* aIndex);
     */
    
#ifdef DKannStaticIndexGen
    
    // Generation of static index
    int FIndex_StaticStart (SIndex* aIndex,
                            unsigned int aNumOptions,		// Number of options per menu
                            unsigned int aMaxOptionLen,		// Maximum number of charaters that an option string can be
                            unsigned int aMaxESFLen,		// Maximum number of charaters that an esf string can be
                            unsigned int aMaxDataLen);		// Maximum number of charaters that a data string can be
    
    int FIndex_StaticReadNext (SIndex* aIndex,
                               unsigned int* aParentId,	// The ID of the parent menu for this option
                               unsigned int* aSeq,		// The sequence number within the menu of this option
                               TChar* aOptStr,			// The string to present for this option
                               unsigned int* aId,		// The menu id to go to if this option is selected
                               TChar* aESF,				// The "entry so far" string to present if this option is selected
                               TByte* aEnd,				// Boolean value indicating the end of the selection at this option
                               TChar* aData,			// Data string for the selection which is completed for this option
                               TKBool* aDone);			// Boolean indicating load is complete
    
    int FIndex_StaticEnd (SIndex* aIndex);
    int FIndex_StaticGen2File (SIndex* aIndex, unsigned int aNumOptions, unsigned int aMaxStrLen, const char* aFileLoc);
    
#endif // DKannStaticIndexGen
    
    // File output functions
    //int FIndex_WriteToFile (SIndex* aIndex, SFileIndex* aFileIndex, TKBool aLargeFile);
    
    // Statefull Lookup functions
    /*
     int FIndex_LookupStart (SIndex*      aIndex, unsigned int aNumOptions);
     int FIndex_LookupEnd (SIndex* aIndex);
     
     int FIndex_LookupRestart (SIndex* aIndex);
     int FIndex_LookupSelectOption (SIndex* aIndex, unsigned int aOptNum);
     int FIndex_LookupMore (SIndex* aIndex);
     int FIndex_LookupBack (SIndex* aIndex);
     int FIndex_LookupGetOptionCount( SIndex* aIndex );
     
     int FIndex_LookupListStart (SIndex* aIndex, TChar* aListStr, unsigned int aMaxListStrLen, unsigned int aLevelLimit);
     int FIndex_LookupListNext (SIndex* aIndex);
     int FIndex_LookupListEnd (SIndex* aIndex);
     */
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // The MemIndex and FileIndex "classes" implement the FIndex "interface"
    //
    ////////////////////////////////////////////////////////////////////////////////////////
    // Mem Index Class
    
    // Construction/Destruction
    int FMemIndex_New (SMemIndex** aMemIndex);
    int FMemIndex_Free (SMemIndex** aMemIndex);
    int FMemIndex_Clear (SMemIndex* aMemIndex);
    
    // Node tree management
    int FMemIndex_AddItem ( SMemIndex*, unsigned int, TChar**, TChar*, unsigned int, unsigned int, TChar*, TChar**, unsigned int );
    int FMemIndex_DeleteItem (SMemIndex*, unsigned int, TChar**);
    int FMemIndex_UpdateItemPriority (SMemIndex*, unsigned int, TChar**, int);
    
    // Loading tree from sources
    int FMemIndex_LoadFromTextFile (SMemIndex*, const char*, TChar, TChar, TChar);
    int FMemIndex_LoadFromIndexFile (SMemIndex*, SFileIndex*);
    int FMemIndex_WriteToIndexFile (SMemIndex*, SFileIndex*, TKBool);
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // File Index Class
    
    // Construction/Destruction
    int FFileIndex_New (SFileIndex**,
                        const char*,           // No extension! We'll add the ".kdx"
                        const unsigned char,   // Split index nodes / optionStr data files
                        enum KFileMode,
                        const time_t fts);     // Embedded file timestamp value may be passed in
    int FFileIndex_Free (SFileIndex**);
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Map Index Class
    
    int FMapIndex_New (SMapIndex**, int);
    SMapNode* FMapIndex_Get (const SMapIndex*, const DFileLocation);
    SMapNode* FMapIndex_Insert (SMapIndex*, const DFileLocation, SFileSubnode*);
    struct SFileSubnode* FMapIndex_Delete (SMapIndex*, const DFileLocation);
    int FMapIndex_Free (SMapIndex** aMapIndex);
    
    char* FMapIndex_Stats (SMapIndex*);
    
    int FMapIndex_LoadFromIndexFile ( SMapIndex*, SFileIndex* );
    int FMapIndex_LoadCache ( SMapIndex**, SFileIndex*, int );
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // FileIndex Cursor Lookup API
    
    enum KFileIndexCursorFlag
    {
        KFIC_AtRoot 		= 1,
        KFIC_AtLastOption 	= 2,
        KFIC_AtData 		= 4,
        KFIC_FieldBegins 	= 8,
        KFIC_FieldEnds 		= 16
    };
    
    enum KFileIndexCursorMove
    {
        KFIC_Home,
        KFIC_Next,
        KFIC_Down
    };
    
    typedef struct SFileIndexCursor
    {
        SFileIndex*			iIndex;
        SMapIndex*          iMap;
        SFileSubnode* 		iSubNode;
        TChar*				iPartialMatchSuffix;
        
        int              	iOptStrLen;
        DFileLocation       iFilePos;
        unsigned			iFlags;
        
        unsigned char       iDebug;
    } SFileIndexCursor;
    
    int	FFileIndexCursor_Initialize( SFileIndexCursor*, SFileIndex*, SMapIndex*, TKBool, TChar*, TChar*, TChar*, size_t );
    int FFileIndexCursor_Move( SFileIndexCursor*, enum KFileIndexCursorMove );
    int FFileIndexCursor_Seek( SFileIndexCursor*, DFileLocation );
    int FFileIndexCursor_Find( SFileIndexCursor*, const TChar* const*, size_t );
    TKBool FFileIndexCursor_IsSplitRead( SFileIndexCursor*);
    int FFileIndexCursor_ReadData( SFileIndexCursor*, DFileLocation, TChar**, TChar** );
    int FFileIndexCursor_ReadDataSubnode( SFileIndexCursor*, DFileLocation, SFileSubnode* );
    int FFileIndexCursor_CacheMap ( SFileIndexCursor*, SFileIndex* );
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // Error codes
    ////////////////////////////////////////////////////////////////////////////////////////
    enum KErr
    {
        KErrNone = 0,
        
        // Warnings
        KWarnMin = 1,
        
        // Lookup warnings
        KWarnPopStackEmpty,	// A pop of the stack occurred but it was empty at the time
        KWarnBlankOption,	// The user selected a blank option, the action is ignored but may indicate an assistance message may be in order
        KWarnTestFailed,	// A test process reported a failure
        KWarnItemNotFound,	// A search for an item in an index failed
        
        // Memory Index warnings
        KWarnNoFieldsForItem,	// Tried to add an item with no fields
        KWarnItemExists,        // duplicate key added
        
        // Cursor API warnings
        KWarnPartialMatch,		// Specified ESF matches a unique node only partially
        
        // More lookup warnings
        KWarnAtRoot,			//	Went back to the root menu
        KWarnAtFieldBoundary,	//	Option string begins a new field
        
        // Errors
        KErrMin = 1000,
        
        // General errors
        KErrLicenseNotValidated,	// An attempt has been made to perform an operation before calling FValidateLicense()
        KErrOutOfMemory,		// An allocation of memory failed
        KErrNullPointer,		// An attempt was made to dereference a null pointer
        KErrFreeNullPointer,	// An attempt was made to free a null pointer
        KErrIndexAbstraction,	// An attempt was made to establish an abstracted object but too many or no sub-objects were specified
        KErrUnimplemented,		// A call was made to an unimplemented method
        KErrOverflow,			// A string or memory access has gone out of the memory range of the object
        KErrSubnodeOverflow,	// We have tried to allocate more than DMemNodeMaxSubnodes sub-nodes in a node
        KErrInvalidString,		// An invalid string was supplied to a function possibly due to incompatible encoding
        
        // Memory Index errors
        KErrEndBranchContinuation,	// When a string is added which is a continuation of an end branch (1010)
        KErrOpenTextFile,		// Error opening a source text file
        KErrReadTextFile,		// Error reading a source text file
        KErrTextFileNotUTF8,	// The source text file specified is not UTF8
        KErrMaxFieldsExceeded,	// A source line was specified with more than DMaxSourceTextFields fields
        KErrNegativePriority,	// An attempt was made to set or adjust a priority to a negative number
        KErrIndexNotClear4Split,	// A call was made to initiate a split file generation but the memory index already has data
        KErrOpenSplitFile,		// There was an error creating a split file
        KErrWriteSplitFile,		// There was an error writing to a split file
        KErrReadSplitFile,		// There was an error reading from a split file
        
        // File Index errors
        KErrCreateIndex,		// Can't create index file     (1020)
        KErrCreateOpenUpdate,	// Can't open index for for update
        KErrCreateOpenRead,		// Can't open index file for reading
        KErrSeekIndex,			// Error while attempting a seek on the index file
        KErrInvalidFileMode,	// Invalid file mode supplied
        KErrCloseIndex,			// Error while closing the index file
        KErrFlushIndex,			// Error while flushing the index file
        KErrGetPos,				// Error while getting the position in the index file
        KErrInvalidMode,		// An attempt to perform a file operation incompatible with the mode in which it was opened
        KErrParmsNotInit,		// An attempt to read the file parameters before they are initialized
        
        KErrWriteIndexHeader,	// An error occurred while writing the index file header (1030)
        KErrReadIndexHeader,	// An error occurred while reading the index file header
        KErrWriteSubnode,		// An error occurred while writing a sub-node record
        KErrReadSubnode,		// An error occurred while reading a sub-node record
        KErrWriteLocation,		// An error occurred while writing a location
        KErrReadLocation,		// An error occurred while reading a location
        KErrWriteLocationOverflow,	// A location to be written is too large (> DMaxFileLoc)
        KErrWriteStrlenOverflow,	// A string length to be written is too large (> DMaxOptionStrLen)
        KErrWritePriorityOverflow,	// A priority value to be written is too large (> DMaxPriority)
        KErrIndexEOF,			// An unexpected EOF was encountered while reading the index file
        
        KErrIncompatCharSys,	// [1040] We are trying to read a file which has been written in an incompatible character system (Unicode or ASCII)
        
        // Lookup errors
        KErrLookupNotInit,		// An attempt was made to perform a lookup operation without the lookup being initialized
        KErrLookupAlreadyInit,	// An attempt was made to initialize a lookup operation which has already been initialized
        KErrLookupInvalidOption,// An attempt was made to access an invalid option
        KErrNoDataBranch,		// The lookup process has got to the end of a branch without encountering a data record
        
        // Static menu generation
        KErrStaticNotInit,		// An attempt was made to perform a static menu generation operation without the process being initialized
        KErrStaticAlreadyInit,	// An attempt was made to initialize a static menu generation operation which has already been initialized
        KErrStaticOutFileError,	// An error occurred when trying to open the output file for writing
        
        // Cursor operations
        KErrCantMoveCursor,		// Trying to move past the end in specified direction
        KErrItemNotFound,		// Item cannot be found in index by its extended ESF
        KErrItemOutOfOrder,
        
        // Map Index Errors
        KErrWriteMapNode,       // MapIndex write error
        KErrInsertDuplicate,    // Duplicate detected on insert operation
        
        // Place holder for last error message
        KErrLast
    };
    
    
#endif // ifndef DKANNUUAPIH
    
#ifdef __cplusplus
}
#endif