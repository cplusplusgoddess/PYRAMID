
############################################
#  Author: 	Amber Rogowicz
#  File	:	Makefile  for building pyramid 
#  Date:	July 2018

CC = g++
# Note: the following are OSX platform flags
# CC = clang++
# CFLAGS  = -v -Wall -std=c++0x -ggdb -fPIC

# adjust flags as necessary for your platform
CFLAGS  = -Wall -fPIC -std=c++11 

#LDFLAGS =  -lpthread

all: main.o  pyramid

pyramid: main.o  
	$(CC) $(CFLAGS) $(LDFLAGS) main.o -o pyramid

main.o: main.cpp pyramid.cpp
	$(CC) $(CFLAGS) -c main.cpp -o main.o



clean:
	rm -rf *.o  pyramid
