//NxN tic-tac-toes
#include <iostream>
#include <cstdlib>
using namespace std;

// The following 3 functions are helper functions to convert
// between 1D and 2D array indices.  The grid itself is stored
// as a 1D array.

/**
 * Helper function - Given the grid array and its dimension
 *    as well as a particular row (r) and column (c), this
 *    function performs the arithmetic to convert r and c
 *    to a 1D index and returns that character in the grid.
 *    For example, for dim = 3 and r = 2, c = 1, this function
 *    should compute the corresponding index: 7 and return
 *    grid[7].
 *
 */
char getEntryAtRC(char grid[], int dim, int r, int c);

/**
 * Helper function - Given a 1D index returns the row
 * that corresponds to this 1D index.  Use this in
 * conjunction with idxToCol() anytime you have a 1D index
 * and want to convert to 2D indices.
 */
int idxToRow(int idx, int dim);

/**
 * Helper function - Given a 1D index returns the column
 * that corresponds to this 1D index.  Use this in
 * conjunction with idxToRow() anytime you have a 1D index
 * and want to convert to 2D indices.
 */
int idxToCol(int idx, int dim);

//prints the board in a nice fashion
void printTTT(char grid[], int dim);

/**
 * Should check if any player has won the game yet.
 *
 * Parameters:
 *   grid: Array of dim^2 characters representing the state
 *         of each square.  Each entry contains 'X', 'O', or '?'
 *
 * Return value:
 *   Should return 1 if 'X' has won, 2 if 'O' has won, or 0 (zero)
 *   if the game is still undecided.
 *
 */
int checkForWinner(char grid[], int dim);


/**
 * Should check if there is no possible way any player can win.
 * More specifically, if there does not exist a row, column,
 * or diagonal that can still have 3 of a kind, then the game
 * will be a draw.
 *
 *
 * Parameters:
 *   grid: Array of dim^2 characters representing the state
 *         of each square.  Each entry contains 'X', 'O', or '?'
 *
 * Return value:
 *   Return true if no player can win given the current
 *   game state, false otherwise.
 */
bool checkForDraw(char grid[], int dim);

/**
 * @brief Get the Ai Choice for the current player and update grid object
 *
 * Parameters:
 *   grid: Array of dim^2 characters representing the state
 *         of each square.  Each entry contains 'X', 'O', or '?'
 *   dim: the dim(-ension) of the tic-tac-toe board
 *   player: current player => 'X' or 'O'
 * @return true If an error occurred or a choice was unable to be made
 * @return false If a play was successfully made
 */
bool getAiChoiceAndUpdateGrid(char grid[], int dim, char player);

/**
 * @brief Picks a random location for the current player and update grid
 *
 * Parameters:
 *   grid: Array of dim^2 characters representing the state
 *         of each square.  Each entry contains 'X', 'O', or '?'
 *   dim: the dim(-ension) of the tic-tac-toe board
 *   player: current player => 'X' or 'O'
 * @return true If no viable location to be played
 * @return false If a play was successfully made
 */
bool getRandChoiceAndUpdateGrid(char grid[], int dim, char player);


/**********************************************************
 *  Write your implementations for each function prototyped
 *  above in the space below
 **********************************************************/

char getEntryAtRC(char grid[], int dim, int r, int c)
{
    int i = (dim * r) + c; /* Convert r,c to 1D index using Address logic */
    return grid[i];
}

int idxToRow(int idx, int dim)
{   //every integer is in the row that corresponds to integer division of dim
    int row = idx / dim; /* convert idx to appropriate row */
    return row; 
}

int idxToCol(int idx, int dim)
{
    int column = idx % dim; /*convert idx to appropriate column */
    return column;
}

void printTTT(char grid[], int dim)
{
    for(int r = 0; r < dim; r++) { //proceeds to next row
      for(int c = 0; c < dim; c++){ //goes to next column
        if(c < dim-1){
          cout << " " << getEntryAtRC(grid, dim, r, c) 
          << " |"; 
        }
        else { //if printing the last column then do not print '|'
          cout << " " << getEntryAtRC(grid, dim, r, c);
        }
      }
    
      cout << endl;
      if(r < dim -1){ //only print if it is not the last row
        for(int d = 0; d < dim*4-1; d++){
          cout << "-";
        }
        cout << endl;
      }
    }
}

int checkForWinner(char grid[], int dim)
{ 
    //using SUCCEED-early/FAIL late 
    //assume someone has won, in the current row/column/diagonal, 
    //and search through to disprove. If it has not been disproven by
    //the end of the end of the function then someone has definitely won
    bool xWon = true;
    bool oWon = true;

    for(int r = 0; r < dim; r++){
      //if the first row didnt have a winner, both conditions will be set to false
      //we need to reset this for every row.
      xWon = true;
      oWon = true;

      for(int c = 0; c < dim; c++){ //walks through rows
        //cout << "line 173 FOUND in row " << r << " " << getEntryAtRC(grid, dim, r, c) << endl;
        if(getEntryAtRC(grid, dim, r, c) != 'X'){
          xWon = false; //X is not at all locations in row
        }
        if(getEntryAtRC(grid, dim, r, c) != 'O'){
          oWon = false;//O is not at all locations in row 
        }  
      }

      if(oWon == true || xWon == true){
        //this condition will pass if program encounters a row that has a winner
        break;
      } 
    }

    //we only want to check columns if rows did not find any winner
    if(xWon == false && oWon == false){
      /* conditions became false due to rows not having a winner, but now
         we need to assume that there is a win in a column, so reset conditions*/

      for(int c = 0; c < dim; c++){ //walks down columns
      oWon = true;
      xWon = true;

        for(int r = 0; r < dim; r++){
          //cout << "line 187 FOUND in column "<< c << " " << getEntryAtRC(grid, dim, r, c) << endl;
          if(getEntryAtRC(grid, dim, r, c) != 'X'){
            xWon = false;//X is not at all locations in column
          }
          if(getEntryAtRC(grid, dim, r, c) != 'O'){
            oWon = false;//O is not at all locations in column
          }
        }
        if(oWon == true || xWon == true){
          break;
        }
      }
    }

    //if we still havent found a winner then it is time to check diagonals
    //diagonal coordinates are always at (x,y) where x = y.
    if(xWon == false && oWon == false){
      oWon = true;
      xWon = true;

      for(int rc = 0; rc < dim; rc++){
        if(getEntryAtRC(grid, dim, rc, rc) != 'X'){
          xWon = false;
        }
        if(getEntryAtRC(grid, dim, rc, rc) != 'O'){
          oWon = false;
        }
      }
    }

    //checking diagonal 2! from top right to bottom left 
    if(xWon == false && oWon == false){
      oWon = true;
      xWon = true;
      for(int rc = 0; rc < dim ; rc++){
        char found = getEntryAtRC(grid, dim, rc, dim-1-rc);

        if(found != 'X'){
          xWon = false;
        }
        if(found  != 'O'){
          oWon = false;
        }
      }
    }

    //time to check if someone won or no one did.
    if(xWon){
     //cout << "xwon" << endl;
      return 1;
    }
    else if(oWon){ /*o has won*/
      //cout << "owon" << endl;
      return 2;
    }
    else {//no one won
      return 0;
    }
}

bool checkForDraw(char grid[], int dim)
{
    //Fail Early/Succeed late, it fails to be a draw until all rows/columns/diagonals
    //prove to be a draw   
    bool isX = false; //is there at least 1 O in every column, row, and diagonal
    bool isO = false; //is there at least 1 O in every column, row, and diagonal

    for(int r = 0; r < dim; r++){
      //individual row checker should be reset
      isX = false;
      isO = false;

      for(int c = 0; c < dim; c++){
        char found = getEntryAtRC(grid, dim, r, c);
        //the found variable that will be used here and everywhere else
        //past this point mean the same thing, it evaluates to the symbol 
        //*found* at that row and column.

        if(found == 'X'){
          isX = true;
        }
        if(found == 'O'){
          isO = true;
        }
      }

      if(isX == false || isO == false){
        //not a draw one of the rows did not have an O or X
        return false;
      }
    }

    //we have checked rows but have not found a row that
    // proves it is not a draw so now we will check columns
    //specifically at columns
    for(int c = 0; c < dim; c++){
      isX = false;
      isO = false;
      for(int r = 0; r < dim; r++){
        char found = getEntryAtRC(grid, dim, r, c);

        if(found == 'X'){
          isX = true;
        }
        if(found == 'O'){
          isO = true;
        }
      }

      if(isX == false || isO == false){
        //not a draw one of the rows did not have an O or X
        return false;
      }
    }

    //we have not found a proof that is not a draw yet, so check diagonals
    isX = false;
    isO = false;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, rc);    

      if(found == 'X'){
        isX = true;
      }
      if(found == 'O'){
        isO = true;
      }
    }

    if(isX == false || isO == false){
      //not a draw one of the rows did not have an O or X
      return false;
    }

    //lastly check the 2nd diagonal for proof no draw
    isX = false;
    isO = false;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, dim-1-rc);

      if(found == 'X'){
        isX = true;
      }
      if(found == 'O'){
        isO = true;
      }
    }

    if(isX == false || isO == false){
      //not a draw one of the rows did not have an O or X
      return false;
    }

    //if after all this we not returned false then it must be a draw
    return true;
 
}


bool getAiChoiceAndUpdateGrid(char grid[], int dim, char player)
{
    /* Logic: winning should be the priority over blocking, as winning
      ends the game. */
    int counterForPlayer = 0;
    int counterFree = 0; //AI will work on counters that must be 
                        //reset after every search iteration

    for(int r = 0; r < dim; r++){
      //this is an individual row search, 
      //so we must 0 the counters after every row
      counterFree = 0;
      counterForPlayer = 0;

      for(int c = 0; c < dim; c++){
        char found = getEntryAtRC(grid, dim, r, c);

        if(found == player){
          counterForPlayer++;
        }
        if(found == '?'){ //only want to play if there is a spot open
          counterFree++;
        }
      }

      //after counting the rows, if counter = dim-1, then
      //AI can win by placing the corresponding players symbol
      //at the '?' in the grid if this row is available.
      if(counterForPlayer == dim-1 && counterFree > 0){
        for(int c = 0; c < dim; c++){
          char found = getEntryAtRC(grid, dim, r, c);

          if(found == '?'){
            grid[(dim * r) + c] = player;
            return true;
          }   
        }
      }
    } //end for loop

    //check for columns possible victories using same logic
    for(int c = 0; c < dim; c++){
      counterFree = 0;
      counterForPlayer = 0; //counter reset after iteration

      for(int r = 0; r < dim; r++){
        char found = getEntryAtRC(grid, dim, r, c);

        if(found == player){
          counterForPlayer++;
        }
        if(found == '?'){
          counterFree++;
        }      
      }

      if(counterForPlayer == dim-1 && counterFree > 0){
        for(int r = 0; r < dim; r++){
          char found = getEntryAtRC(grid, dim, r, c);

          if(found == '?'){
            grid[(dim * r) + c] = player;
            return true;
          }       
        }
      }
    } //end for loop


    //now for diagonals!!!!
    counterForPlayer = 0;
    counterFree = 0;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, rc);

      if(found == player){
        counterForPlayer++;
      }
      if(found == '?'){
        counterFree++;
      }
    }//end for loop
    
    //finding where to put the player symbol
    if(counterForPlayer == dim-1 && counterFree > 0){
      for(int rc = 0; rc < dim; rc++){
        char found = getEntryAtRC(grid, dim, rc, rc);

        if(found == '?'){
          grid[(dim * rc) + rc] = player;
          return true;
        }       
      }
    }

    counterForPlayer = 0;
    counterFree = 0;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, dim-1-rc);

      if(found == player){
        counterForPlayer++;
      }
      if(found == '?'){
        counterFree++;
      }
    }//end for loop
    if(counterForPlayer == dim-1 && counterFree > 0){
      for(int rc = 0; rc < dim; rc++){
        char found = getEntryAtRC(grid, dim, rc, dim-1-rc);

        if(found == '?'){
          grid[(dim * rc) + dim-1-rc] = player;
          return true;
        }       
      }
    }//end of if

    //if we have reached line 452 then the AI has not found a winnable spot.
    //Therefore it should attempt to block.
    //To block the AI must find any != player spots that are != '?', which are the
    // enemy spots.
    //If enemy spots = dim-1 and there is a '?' spot, then there is a spot that must be blocked. 
    int counterForEnemy = 0;
    counterFree = 0;

    //the AI will first search through rows.
    for(int r = 0; r < dim; r++){
      //this is an individual row search, 
      //so we must 0 the counters after every row
      counterFree = 0;
      counterForEnemy = 0;
      for(int c = 0; c < dim; c++){
        char found = getEntryAtRC(grid, dim, r, c);

        if(found != player && found != '?'){
          counterForEnemy++;
        }
        if(found == '?'){
          counterFree++;
        }
        
      }// end of column loop

      //after counting the rows, if counter = dim-1, then
      //AI should block by placing the corresponding players symbol
      //at the '?' in the grid if this row is available.
      if(counterForEnemy == dim-1 && counterFree > 0){
        for(int c = 0; c < dim; c++){
          char found = getEntryAtRC(grid, dim, r, c);

          if(found == '?'){
            grid[(dim * r) + c] = player;
            return true;
          }        
        }
      }
    } //end row loop search

    //now the same logic but for columns
    for(int c = 0; c < dim; c++){
      counterFree = 0;
      counterForEnemy = 0;

      for(int r = 0; r < dim; r++){
        char found = getEntryAtRC(grid, dim, r, c);

        if(found != player && found != '?'){
          counterForEnemy++;
        }
        if(found == '?'){
          counterFree++;
        }      
      }

      if(counterForEnemy == dim-1 && counterFree > 0){
        for(int r = 0; r < dim; r++){
          char found = getEntryAtRC(grid, dim, r, c);
          if(found == '?'){
            grid[(dim * r) + c] = player;
            return true;
          }       
        }
      }
    } //end for loop


    //now for diagonals!!!!
    counterForEnemy = 0;
    counterFree = 0;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, rc);

      if(found != player && found != '?'){
        counterForEnemy++;
      }
      if(found == '?'){
        counterFree++;
      }
    }//end for loop

    //places player symbol at ?
    if(counterForEnemy == dim-1 && counterFree > 0){
      for(int rc = 0; rc < dim; rc++){
        char found = getEntryAtRC(grid, dim, rc, rc);

        if(found == '?'){
          grid[(dim * rc) + rc] = player;
          return true;
        }       
      }
    }

    //other diagonal
    counterForEnemy = 0;
    counterFree = 0;
    for(int rc = 0; rc < dim; rc++){
      char found = getEntryAtRC(grid, dim, rc, dim-1-rc);

      if(found != player && found != '?'){
        counterForPlayer++;
      }
      if(found == '?'){
        counterFree++;
      }
    }//end for loop

    //places player symbol - same code as above.
    if(counterForEnemy == dim-1 && counterFree > 0){
      for(int rc = 0; rc < dim; rc++){
        char found = getEntryAtRC(grid, dim, rc, dim-1-rc);
        if(found == '?'){
          grid[(dim * rc) + dim-1-rc] = player;
          return true;
        }       
      }
    }//end of if
    
    //no viable location
    return false;
}


// Complete...Do not alter
bool getRandChoiceAndUpdateGrid(char grid[], int dim, char player)
{
    int start = rand()%(dim*dim);
      // look for an open location to play based on random starting location.
      // If that location is occupied, move on sequentially until wrapping and
      // trying all locations
    for(int i=0; i < dim*dim; i++) {
      int loc = (start + i) % (dim*dim);

      if(grid[ loc ] == '?') {
        grid[ loc ] = player;
        return false;
      }
    }
    // No viable location
    return true;
}


/**********************************************************
 *  Complete the indicated parts of main(), below.
 **********************************************************/
int main()
{
    // This array holds the actual board/grid of X and Os. It is sized
    // for the biggest possible case (11x11), but you should only
    // use dim^2 entries (i.e. if dim=3, only use 9 entries: 0 to 8)
    char tttdata[121];

    // dim stands for dimension and is the side length of the
    // tic-tac-toe board i.e. dim x dim (3x3 or 5x5).
    int dim;
    int seed;

    // Get the dimension from the user
    cin >> dim >> seed;
    srand(seed);

    int dim_sq = dim*dim;

    for(int i=0; i < dim_sq; i++) {
        tttdata[i] = '?';
    }

    // Print one of these messages when the game is over
    // and before you quit
    const char xwins_msg[] = "X player wins!";
    const char owins_msg[] = "O player wins!";
    const char draw_msg[] =  "Draw...game over!";

    bool done = false;
    char player = 'X';

    // Show the initial starting board
    printTTT(tttdata, dim);


    //my initializations
    int input; //
    int whoWon; //will determine who won, 1 for x, 2 for o
    bool isDraw;//will be used to determine if a draw happened

    while(!done) {
      // Get the current player's input or choice of AI or Random
      // location and update the tttdata array.
      cout << "Player " << player << " enter your square choice [0-" 
      << dim_sq-1 << "], -1 (AI), or -2 (Random):" << endl;
      cin >> input;

      while(input < dim_sq && input >= -2){
        //if not a valid input code should break!

        if(input != -1 && input != -2){
          //then it is a valid input not calling for AI

          // Show the updated board if the user eventually chose a valid location
          while(tttdata[input] == '?' && input < dim_sq){ 
            tttdata[input] = player;
            printTTT(tttdata, dim); //print updated board

            isDraw = checkForDraw(tttdata, dim); //call draw checker and give the value to isDraw
            whoWon = checkForWinner(tttdata, dim); //call win cheker and give the value to whoWon

            /***winner/draw check***/
            if(isDraw == true){ //then it is a draw
              cout << draw_msg << endl;
              return 0;
            }
            if(whoWon == 1){//x has won
              cout << xwins_msg << endl;
              return 0;
            }
            else if(whoWon == 2){//o has won
              cout << owins_msg << endl;
              return 0;
            }

            //switch turns
            if(player == 'X'){
              player = 'O'; // x -> o
            }
            else if(player == 'O'){
              player = 'X'; // o -> x
            }
            /***********************/

            //prompt user to input
            cout << "Player " << player << " enter your square choice [0-" 
            << dim_sq-1 << "], -1 (AI), or -2 (Random):" << endl;
            cin >> input;

            
          } //end while loop

          //user inputed occupied location
          if(tttdata[input] != '?' && input != -1 && input != -2) { 
            cout << "Player " << player << " enter your square choice [0-" 
            << dim_sq-1 << "], -1 (AI), or -2 (Random):" << endl;
            cin >> input;
          }
        } //end of if statement for normal user input

      if(input == -1){ //ai will play
        bool aiPlay = false; //if ai did not play this will stay false 
                            //so dont update turns

        //cout << "entering AI function " << endl;
        aiPlay = getAiChoiceAndUpdateGrid(tttdata, dim, player);
        printTTT(tttdata, dim); //update board after AI choice

        isDraw = checkForDraw(tttdata, dim); //check for draw
        whoWon = checkForWinner(tttdata, dim); //check for win

        /***winner/draw check***/
        if(isDraw == true){
          cout << draw_msg << endl;
          return 0;
        }
        if(whoWon == 1){
          cout << xwins_msg << endl;
          return 0;
        }
        else if(whoWon == 2){
          cout << owins_msg << endl;
          return 0;
        }
        /***********************/

        if(aiPlay == true){
          //then getAi... found a viable spot and it is the next player's turn
          //switch turns 
          if(player == 'X'){
            player = 'O'; //x -> o
          }
          else if (player == 'O'){
            player = 'X'; //o -> x
          }
        }

        //user input time
        cout << "Player " << player << " enter your square choice [0-" 
        << dim_sq-1 << "], -1 (AI), or -2 (Random):" << endl;
        cin >> input;
      }

      if(input == -2){ //user has chosen to play randomly
        bool randomPlay = getRandChoiceAndUpdateGrid(tttdata, dim, player);
        printTTT(tttdata, dim); //update board

        isDraw = checkForDraw(tttdata, dim);
        whoWon = checkForWinner(tttdata, dim);

        /***winner/draw check***/
        if(isDraw == true){
          cout << draw_msg << endl;
          return 0;
        }
        if(whoWon == 1){
          cout << xwins_msg << endl;
          return 0;
        }
        else if(whoWon == 2){
          cout << owins_msg << endl;
          return 0;
        }
        /*************************/

        if(randomPlay == false){
          //then getRand... found a viable spot and it is the next player's turn
          //switch turns x -> o; o -> x
          if(player == 'X'){
            player = 'O';
          }
          else if (player == 'O'){
            player = 'X';
          }
        }

        //user input :D
        cout << "Player " << player << " enter your square choice [0-" 
        << dim_sq-1 << "], -1 (AI), or -2 (Random):" << endl;
        cin >> input;
      }

      //bad input -> END CODE!
      if(input > dim_sq || input < -2){
          return 0;
      }
    }   
      done = true;
   } // end while
    return 0;
}

//end of program :D