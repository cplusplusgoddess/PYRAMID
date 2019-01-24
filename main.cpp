// ############################################
// Author: 	Amber Rogowicz
// File	:	main.cpp   main driver for running pyramid 
// Date:	Jan 2019
// ############################################
//
//					INPUT: An input file passed to the program as a parameter
//					specifies:
//					the target and input of the pyramid is retrieved from
//                  a file with the following syntax e.g.
// Target: 720
// 2
// 4 3				where there are SPACES and NO COMMAS separating the 
// 3 2 6			numbers ...numbers can be on any number of lines
// 2 9 5 2
// 10 5 2 15 5
// 
//					OUTPUT:
//						output is to the command line or standard output
//						in the form of "L R L" where L = left  R = right
//						traversal down the pyramid

#include <iostream>
#include <string>
#include "pyramid.cc"

using namespace std;


static void show_usage(std::string name)
{
    std::cerr << "Usage: " << name << "  | -h | inputFILENAME \n"
              << "\t-h,--help\t\tShow this help message\n"
              << std::endl;
}
int main(int argc, char *argv[]) 
{
   	std::string arg  = argv[1];
	int target;

    // Check the command line arguments
    if ((arg == "-h") || (arg == "--help") || (argc < 2 ))
	{
        // user  is asking for help to run the program
        show_usage(argv[0]);
        return(1);
   	}
	// open up the input file and read in the data to the 
	// Pyramid Object
    ifstream infile(arg);
	if (infile.is_open())  
	{

	    infile.ignore( std::numeric_limits<std::streamsize>::max(), ':' ); // ignore "Target:
	    infile >> target;

	}else{
		cout << "Could not open file: " << arg ;
		return(1);
		
	
	} 
	// read in the target integer
	Pyramid pyramid;

    try{
	  if( SUCCESS == pyramid.build( infile ))

	  { //loop thru bottom elements for a path with a target
		//pyramid.print();
		infile.close();
		string	pathStr;
		bool result      =  FAIL;
  		result = pyramid.getPath( target, 0, 0 , pathStr);
		//cout << "\n Target: " << target << endl;
		//cout << "\n Status: " << ((result==FAIL)?" FAIL":"SUCCESS") << endl;
		cout << "\n Path: " << pathStr << endl;

      }// end if building successful pyramid
	}catch(const ios::failure& error){
		cerr << "I/O exception " << error.what() << endl;
		infile.close();
		return EXIT_FAILURE;
	}catch(...){
		cout << "Unknown Problem reading the file " << arg ;
		infile.close();
		return EXIT_FAILURE;
	} // end build pyramid fail
	exit(0);
} // end main()

