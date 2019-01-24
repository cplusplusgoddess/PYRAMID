Pyramid/main.cpp                                                                                    000755  000765  000024  00000004601 13422225225 015315  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                         // ############################################
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

                                                                                                                               Pyramid/pyramid.cc                                                                                  000644  000765  000024  00000014514 13422224770 015646  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                         //-------------------------------------------------------------------
// Pyramid.cc 
//                class definition for handling path solutions thru
//                a pyramid structure
//      5		  which when traversing from top to bottom can only
//    L /\ R      move to either left or right decendant, where each
//     /  \		  node has a value that is multipled to a running 
//    3    4      target value that ends at the bottom or leaf nodes
//  L /\R /\      of the tree. The traversal of this tree will create
//   /  \/  \     a string path consisting of "L" and "R"s that denote
//  2    7   8    the direction of travel from the top down. 
//  /\  /\  /\
// /  \/  \/  \   Example: the path "L L L" would generate a target of
//10  5   6    9           300 = 5 x 3 x 2 x 10
//                         "L L R" = 150
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
//          2				
//		 4     3			
//	   3    2    6		
//   2   9    5    2	
//10   5    2   15   5  target 720 = "
//
//   The Pyramid is made of Rungs or Levels which contain a pointer to
//   sequential array of (Level+1)blocks
//   
//   Rung - Level, int[Level+1] Blocks
//   vector<Rung> Pyramid 
//-------------------------------------------------------------------

#ifndef	PYRAMID_CC
#define	PYRAMID_CC
#include <cstdlib>
#include <cassert>
#include <utility>
#include <vector>
#include <iostream>
#include <fstream>
using namespace std; 
const char LEFTSTR[] = "L ";
const char RIGHTSTR[] = "R ";
const bool SUCCESS = 1;
const bool FAIL    = 0;

	class Rung 
	{
	public:
		Rung( int idx )
		{
			level = idx;
			blocks = new int[level+1];
		}
		 ~Rung()
		 { delete[] blocks;
			blocks=nullptr;
		 }
		
    	Rung(Rung const& other) // copy constructor
    	{
			level = other.level;
			blocks = new int[level+1];
        	memcpy(blocks, other.blocks, sizeof(int)*(level+1));   // duplicate all that data
		}

		friend void swap ( Rung & rungTo, Rung &rungFrom )
		{
			using std::swap;
			swap(rungTo.level, rungFrom.level); 
   		    swap(rungTo.blocks, rungFrom.blocks);
		}

    Rung(Rung&& other):  // move constructor
        	level(std::move(other.level)), blocks(std::move(other.blocks)) // move the data: no copies
    {
	}

	Rung& operator=(Rung const& other) // copy-assignment
    {
		if( this != &other )
		{
			delete [] blocks;
			blocks = nullptr;
			level = other.level;
			blocks = new int[level+1];
       		std::copy( other.blocks, other.blocks + (other.level + 1), blocks); // copy all the data
		}
       	return *this;
    }

    Rung& operator=(Rung other) // move-assignment
	{
		swap(*this, other );
		return *this;
	}

    Rung& operator=(Rung && other) // move-assignment
    {
		level = std::move(other.level);
        blocks= std::move(other.blocks); // move the data: no copies
        return *this;
    }

  
	void print()
	{ 
			cout << "Level: " << level << "\t"; 
			for(int i=0; i < level+1; i++ )
			    cout << blocks[i] << "    " ; 
	}

        // overload [] operator.  
	int &operator[](int index) 
	{ 
			assert (index <=(level+1)) ;
    		return (blocks[index]); 
	} 
 

	public:
			int level;
		 	int *blocks; // allocated memory at construct time
	};

	class Pyramid 
	{
	public: 
		bool build( std::ifstream &infile )
 		{	
			int rungIdx=0, blockIdx = 0, blockval;
			Rung *rung = new Rung(rungIdx );
			while( infile >> blockval) 
			{
				rung->blocks[blockIdx] = blockval;
				blockIdx++;
				if( blockIdx > rungIdx )
				{
					levels.push_back(*rung);
					rungIdx++;
				    blockIdx=0;
					rung = new Rung(rungIdx );
					continue;
				}
			}
			if( !infile.eof() ) // if we havent reached the end of the input file, problem
			{
				throw( std::ios::failure ("input error in Pyramid::build()" ));
			}
			return SUCCESS;
		}// end build

		int  size(void)
        {   return levels.size();
		}

		//--------------------------------------------------------------
		// getPath() Recursive method to find a path from the top of the
		//			pyramid to the bottom that computes the product == target
		//			It divides the target by the current block and 
		//			traverses the pyramid to the left child and if a failure
		//			occurs, tries the right child
		//			it attempts to be more efficient by just testing equality
		//			for the target and block on the bottom rung of the pyramid
		//			and does a modulus test == 0 on the current block value
		//			to quit seeking further down the pyramid from this failed
		//			block
		bool getPath( int target, int rungIdx, int childIdx, string &path )
		{
			int block_val = get_block(rungIdx, childIdx) ;
			if( block_val == 0 ) 
			{
				throw( std::ios::failure ("in attempt to divide by zero Pyramid::getPath()" ));
			}
			// cout << "getPath: Target Eval block of Rung " << target << "  : " 
					//<< block_val << " : " << rungIdx << endl;
			if( rungIdx == (size() - 1 ) ) // we are at the bottom
			{ 
				// If were at the bottom just compare with target
				if( block_val == target )
				{
					return SUCCESS;
				}else
				{	
					path.clear();
					return FAIL;
				}
			}

			// test the current block modulus with target
			if( (target% block_val) != 0 )
			{	
					return FAIL;
			} 
			target = target/block_val;
			bool rResult=FAIL, lResult=FAIL;
			if( !(lResult = getPath( target, rungIdx+1, childIdx, path )) && 
					!( rResult = getPath( target, rungIdx+1, childIdx+1, path )))
			{
					path.clear();
					return FAIL;
			} 
			// While we unravel from our recursion, construct our path by adding to the
			// front of the path string
			path.insert(0, ((lResult == SUCCESS)? LEFTSTR:RIGHTSTR));
			return SUCCESS;
		
		}

		int & get_block( int rung, int blockno )
		{ 
			assert (rung < levels.size()) ;
			assert (blockno <= (rung + 1));
    		return ((levels[rung])[blockno] ); 
		} 
		void print()
		{
				for( int i = 0; i < levels.size(); i++)
				{
					levels[i].print();
					cout << endl;
				}

		}
	private:
		vector<Rung> levels;
	};
#endif	// PYRAMID_CC

                                                                                                                                                                                    Pyramid/._pyramid_sample_input.txt                                                                  000666  000765  000024  00000001145 13422214452 021071  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2  3     e                                      ATTR      e  8  -                 8     com.apple.TextEncoding     G     com.apple.lastuseddate#PS      W   �  %com.apple.metadata:kMDItemWhereFroms      Y  7com.apple.metadata:kMDLabel_o5zvs4pzssq4tx4adrtcfuam4a   utf-8;134217984�I\    �C\    bplist00�_Ghttps://artofproblemsolving.com/assets/careers/pyramid_sample_input.txt_:https://artofproblemsolving.com/company/careers/developersU                            ��q"~���7V��DG�_����)�������p�JE���7��ydΖx���)��j�p#l9cO�!̡�k�U�]~�}yr�$                                                                                                                                                                                                                                                                                                                                                                                                                           Pyramid/pyramid_sample_input.txt                                                                    000666  000765  000024  00000000062 13422214452 020651  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                         Target: 720
2
4 3
3 2 6
2 9 5 2
10 5 2 15 5
                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Pyramid/._pyramid_sample_output.txt                                                                 000666  000765  000024  00000000763 13377341371 021311  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                             Mac OS X            	   2  �     �                                      ATTR      �   �                    �     com.apple.lastuseddate#PS          �  %com.apple.metadata:kMDItemWhereFroms   �   =  com.apple.quarantine I\    �B�
    bplist00�_Hhttps://artofproblemsolving.com/assets/careers/pyramid_sample_output.txt_:https://artofproblemsolving.com/company/careers/developersV                            �q/0081;5bfdc2fc;Firefox;713D335D-C70F-4AE0-A4CC-56A59DD37CD2              Pyramid/pyramid_sample_output.txt                                                                   000666  000765  000024  00000000006 13377341371 021062  0                                                                                                    ustar 00AmberWaves                      staff                           000000  000000                                                                                                                                                                         LRLL
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          