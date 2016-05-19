# makes fat binary for simulator 
# TODO: make universal script for device builds as well

IOS_SIMULATOR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk 
IOS_SIMULATOR_INCLUDE = $(PLATFORM)/usr/include

INSTALL_PREFIX = /usr
INSTALL_HEADERS = $(INSTALL_PREFIX)/include/hiberlite
INSTALL_LIB = $(INSTALL_PREFIX)/lib

all : libhiberlite.a sqlite3.o tests sample

OBJS=BeanLoader.o BeanUpdater.o ChildKiller.o CppModel.o Database.o ModelExtractor.o Registry.o SQLiteStmt.o Visitor.o shared_res.o sqlite3.o

# compiler flags select wisely for ios simulator / ios device

#	-miphoneos-version-min=7.0
#    -mios-simulator-version-min=9.3 

ARCH_IOS = -arch armv7
ARCH_IOS_SIMULATOR = -arch i386 -arch x86_64 

CXXFLAGS = -std=c++11 -arch i386 -arch x86_64 -Iinclude/ -Wall -Isqlite-amalgamation -isysroot $(IOS_SIMULATOR) -mios-simulator-version-min=9.3 
LDFLAGS = -lpthread -ldl -arch i386 -arch x86_64 -isysroot $(IOS_SIMULATOR)
CFLAGS = -arch i386 -arch x86_64 -isysroot $(IOS_SIMULATOR) -std=gnu99 -mios-simulator-version-min=9.3 

libhiberlite.a : $(OBJS)
#	ar rcs libhiberlite.a $(OBJS)
	libtool -static  -syslibroot $(IOS_SIMULATOR) $(OBJS) -o libhiberlite.a  #-arch_only i386


tests : libhiberlite.a

install :
	mkdir -p $(INSTALL_HEADERS)
	cp include/* $(INSTALL_HEADERS)/
	mkdir -p $(INSTALL_LIB)
	cp libhiberlite.a $(INSTALL_LIB)/

sqlite3.o :
	gcc -c $(CFLAGS) sqlite-amalgamation/sqlite3.c -o sqlite3.o

%.o : src/%.cpp include/*
	g++ -c $(CXXFLAGS) $< -o $@

tests : tests.cpp libhiberlite.a
	g++ $(CXXFLAGS) -L./ tests.cpp -o tests -lhiberlite $(LDFLAGS)

sample : sample.cpp libhiberlite.a
	g++ $(CXXFLAGS) -L./ sample.cpp -o sample -lhiberlite $(LDFLAGS)

clean:
	rm -rf *.o tests sample
