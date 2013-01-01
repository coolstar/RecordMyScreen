/*
 *  IOMobileFramebuffer.h
 *  iPhoneVNCServer
 *
 *  Created by Steven Troughton-Smith on 25/08/2008.
 *  Copyright 2008 Steven Troughton-Smith. All rights reserved.
 *
 *  Disassembly work by Zodttd
 *
 */

#include <IOKit/IOTypes.h>
#include <IOKit/IOKitLib.h>
#include <CoreSurface/CoreSurface.h>

#include <stdio.h> // For mprotect
#include <sys/mman.h>

#define kIOMobileFramebufferError 0xE0000000

typedef kern_return_t IOMobileFramebufferReturn;
typedef io_service_t IOMobileFramebufferService;
typedef io_connect_t IOMobileFramebufferConnection;

/*! @function IOMobileFramebufferOpen
 @abstract Basically wraps IOServiceOpen, works the same way as the documented method
 @param service The io_service_t you get from IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOMobileFramebuffer"))
 @param owningTask Use mach_task_self()
 @param type Currently unknown
 @param connection A pointer to your new connection
 @result A IOMobileFramebufferReturn error code. */

IOMobileFramebufferReturn
IOMobileFramebufferOpen(
						IOMobileFramebufferService service,
						task_port_t owningTask,
						unsigned int type,
						IOMobileFramebufferConnection * connection );

/*! @function IOMobileFramebufferGetLayerDefaultSurface
 @abstract Gets the CALayer associated with the display
 @param connection Your connection pointer
 @param surface Your surface ID
 @param layer A pointer to your new layer
 @result A IOMobileFramebufferReturn error code. */

IOMobileFramebufferReturn
IOMobileFramebufferGetLayerDefaultSurface(
										  IOMobileFramebufferConnection connection,
										  int surface,
										  CoreSurfaceBufferRef *ptr);

IOMobileFramebufferReturn
IOMobileFramebufferSwapBegin(
                             IOMobileFramebufferConnection connection,
                             int *token);

IOMobileFramebufferReturn
IOMobileFramebufferSwapEnd(
                           IOMobileFramebufferConnection connection);

IOMobileFramebufferReturn
IOMobileFramebufferSwapSetLayer(
                                IOMobileFramebufferConnection connection,
                                int layerid,
                                CoreSurfaceBufferRef surface);

IOMobileFramebufferReturn
IOMobileFramebufferSwapWait(
                            IOMobileFramebufferConnection connection,
                            int token,
                            int something);

//IOMobileFramebufferReturn
//IOMobileFramebufferGetID(
//						 IOMobileFramebufferService *connect,
//						 CFTypeID *id );

/*
 IOMobileFramebufferGetDisplaySize(io_connect_t connect, CGSize *t);
 */