//-------------------------------------------------------------------
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
//			INPUT: An input file passed to the program as a parameter
//			specifies: the target and input integers contained in blocks
//			and are retrieved from a file with the following syntax e.g.
//
// Target: 720
// 2
// 4 3				where there are SPACES and NO COMMAS separating the 
// 3 2 6			numbers ...numbers can be on any number of lines
// 2 9 5 2
// 10 5 2 15 5
// 
//			OUTPUT:
//			output is to the command line or standard output
//			in the form of "L R L" where L = left  R = right
//			traversal down the pyramid
// Target: 720
//    2				
//   4 3			
//  3 2 6		
// 2 9 5 2	
//10 5 2 15 5  target 720 = " L R L L"
//
//   The Pyramid is made of Rungs or Levels which contain a pointer to
//   an allocated sequential array of (Level+1)blocks
//   
//   Rung - Level, int[Level+1] Blocks containing integer values 
//   vector<Rung> Pyramid  containing num of levels instances of Rungs
//
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
		{ 
			delete[] blocks;
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
	  {   
		return levels.size();
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
	  if( block_val == 0 )  // edge case
	  {
		 throw( std::ios::failure ("in attempt to divide by zero Pyramid::getPath()" ));
	  }
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
		  !(rResult = getPath( target, rungIdx+1, childIdx+1, path )))
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

	};   // end class pyramid
#endif	// PYRAMID_CPP

