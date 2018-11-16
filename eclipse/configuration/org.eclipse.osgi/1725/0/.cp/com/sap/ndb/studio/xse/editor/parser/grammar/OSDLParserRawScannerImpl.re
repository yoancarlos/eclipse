package com.sap.ndb.studio.xse.editor.parser.grammar;

import java.util.ArrayList;

import com.sap.rnd.rndrt.Category;
import com.sap.rnd.rndrt.Constants;
import com.sap.rnd.rndrt.CursorPos;
import com.sap.rnd.rndrt.ErrorState;
import com.sap.rnd.rndrt.IRNDRawScanner;
import com.sap.rnd.rndrt.ITokenIndexResolver;
import com.sap.rnd.rndrt.Token;

/**
 * Implementation for the raw OSDL (XSOData definition language) scanner
 * @author I016373
 *
 */
public class OSDLParserRawScannerImpl implements IRNDRawScanner {

     static final int firstColumnOn = 1;
     
	private int long_head;
	@SuppressWarnings("unused")
	private int long_pos;
	@SuppressWarnings("unused")
	private int long_line; 
	
	/**
	 * A small class representing 
	 * a tupel of token index
	 * and category 
	 */
	static class NumCat
	{
		public NumCat(int i, Category cat) {
			m_num = i; 
			m_cat = cat;
		}
		public NumCat() {
		}
		public int m_num = 0; 
		public Category m_cat = Category.CAT_UNDEF;
	}

	static final int BSIZE	= 8192;

	static final int EOI_MARK = 0;

	static final int CONTINUE_MARK = -333;

	int YYCURSOR() {

		return this.cursor;

	}



	//	#define	YYLIMIT		s->lim

	int YYLIMIT() {

		return this.s.lim;

	}



	int YYMARKER() {

		return this.s.ptr;

	}



	char PTR_YYCURSOR() {

		return this.s.get(this.cursor);

	}



//	#define	YYMARKER	s->ptr

//	#define	YYFILL(n)	{cursor = fill(s, cursor);}

	void YYFILL(int n) {

		this.cursor = fill(this.s, this.cursor);

	}



/*

        re2j:define:YYCTYPE  = "char";

        re2j:define:YYCURSOR  = "cursor";

        re2j:define:YYMARKER  = "this.s.ptr";

        re2j:define:YYLIMIT  = "this.s.lim";

        re2j:define:YYDATA  = "this.s.buffer";

        re2j:yyfill:parameter  = 0;

        re2j:define:YYFILL  = "this.cursor = fill(this.s, this.cursor) this.s.buffer = s.get(cursor);";



*/

	int cursor = 0;

	NumCat RET(int i,Category cat) {
		this.s.cur = this.cursor;
		return new NumCat(i,cat);
	}



	XScanner s = null;



	class XScanner {

		String str;

		char buffer[];



		char get(int index) {

			if (index < this.str.length()) {

			return this.str.charAt(index);

		}

		return '\0';

		}



		XScanner(String s, int line, int column) {

			this.str = s;

			this.lim = s.length();

			this.buffer = (s + "\0").toCharArray(); //$NON-NLS-1$

			//		this.bot = 0;

			this.tok = 0;

			this.ptr = 0;

			this.cur = 0;

			this.pos = 0 + 0 - column;
			this.line = line;

		}



//		int bot; // begin of buffe r

	    int tok; // begin of token

	    int ptr;

	    int cur; // end of token

	    int pos; // begin of line

	    int lim;

	    int		line; // line nr

	};



	int fill(XScanner s, int cursor) {

	  return cursor;

	}

	NumCat scan(XScanner s) {
		this.cursor = s.cur;
		
		/* begin of ... for multiline entities */
		this.long_head = s.cur;
		this.long_pos = s.cur;
		this.long_line = 0;
		
		while (true) {

  /*CCQ_OFF */

			/*normal:*/ s.tok = this.cursor;



/*!re2j



       re2j:define:YYCTYPE  = "char";

        re2j:define:YYCURSOR  = "cursor";

        re2j:define:YYMARKER  = "this.s.ptr";

        re2j:define:YYLIMIT  = "this.s.lim";

        re2j:define:YYDATA  = "this.s.buffer";

        re2j:yyfill:parameter  = 0;
        re2j:define:YYFILL  = "this.cursor = fill(this.s, this.cursor); if(this.cursor >= this.s.lim) return RET(EOI_MARK,Category.CAT_WS);  ";



any	= [\000-\377];

Octal	= [0-7];

Digit	= [0-9];

Letter	= [a-zA-Z_];

Alphabetic = (Letter|[$]);

Alphanumeric = (Alphabetic|Digit);

Hex	= [a-fA-F0-9];

Exp	= [Ee] [+-]? Digit+;

FS	= [fFlL];

IS	= [uUlL]*;

ESC	= [\\] ([abfnrtv?'"\\] | "x" Hex+ | Octal+);

letter_or_digit = [Letter|Digit];

PACKAGE = (Alphanumeric)+ ([\.] (Alphanumeric)+)* ;

IDENT = Alphabetic (Alphanumeric)*  ; 

horiz_space           =     [ \t\f];
unix_like_newline     =     [\n|\r];
non_unix_like_newline =     [\r\n];
newline               =     (unix_like_newline|non_unix_like_newline);
non_newline           =     [^\n\r];
space                 =     (horiz_space|newline);
quote                 =     ['];

*/



/*!re2j

  "/*"			{ 	
  					this.long_head = this.cursor - 2;
					this.long_line = this.s.line;
					this.long_pos = this.s.pos;
  					NumCat res = comment();
						if (res.m_num == CONTINUE_MARK) {
							continue;
						}
						if (res.m_num == OSDLParserTokens.NUM_COMMENT1) {
							return res;
						}
						if (res.m_num == EOI_MARK) {
							return RET(EOI_MARK, Category.CAT_WS);
						} 
              }

              
        

  "."     { return RET(OSDLParserTokens.NUM_DOT,Category.CAT_OPERATOR); }
  ","     { return RET(OSDLParserTokens.NUM_COMMA,Category.CAT_OPERATOR); }
  ":"     { return RET(OSDLParserTokens.NUM_COLON,Category.CAT_OPERATOR); }
  ";"     { return RET(OSDLParserTokens.NUM_SEMICOLON,Category.CAT_OPERATOR); }
  "("     { return RET(OSDLParserTokens.NUM_LPAREN,Category.CAT_OPERATOR); }
  ")"     { return RET(OSDLParserTokens.NUM_RPAREN,Category.CAT_OPERATOR); }
  "{"     { return RET(OSDLParserTokens.NUM_LCURLY,Category.CAT_OPERATOR); }
  "}"     { return RET(OSDLParserTokens.NUM_RCURLY,Category.CAT_OPERATOR); }
  
    "//"    { 	
    
    					this.long_head = this.cursor - 2;
						this.long_line = this.s.line;
						this.long_pos = this.s.pos;
  						NumCat res = oneLineComment();
						if (res.m_num == CONTINUE_MARK) {
							continue;
						}
						if (res.m_num == OSDLParserTokens.NUM_COMMENT2) {
							return res;
						}
						if (res.m_num == EOI_MARK) {
							return RET(EOI_MARK, Category.CAT_WS);
						} 
              }
              
 
  ["][1]["]
		{ return RET(OSDLParserTokens.MULTIPLICITY_ONE,Category.CAT_MAYBE_KEYWORD); }        
  ["][\*]["]
		{ return RET(OSDLParserTokens.MULTIPLICITY_MANY,Category.CAT_MAYBE_KEYWORD); }        
  ["]([0][\.][\.][1])["]
		{ return RET(OSDLParserTokens.MULTIPLICITY_ZERO_OR_ONE,Category.CAT_MAYBE_KEYWORD); }        
  ["]([1][\.][\.][\*])["]
		{ return RET(OSDLParserTokens.MULTIPLICITY_ONE_OR_MORE,Category.CAT_MAYBE_KEYWORD); }        
 
  IDENT		
  		{ return RET(OSDLParserTokens.NUM_ID,Category.CAT_IDENTIFIER); }
  ["][^"][^"]*[(\:\:)][^"][^"]*["]
  		{ return RET(OSDLParserTokens.NUM_REPOBJECT,Category.CAT_IDENTIFIER); }  		
  ["][^"]*["][\.]["][^"]*["]
  		{ return RET(OSDLParserTokens.NUM_CATOBJECT,Category.CAT_IDENTIFIER); }  		
  ["][^"]*["]		
  		{ return RET(OSDLParserTokens.NUM_QUOTED_ID,Category.CAT_IDENTIFIER); }

   
          
  [ \t\r]+		{ continue; //goto normal; 

                    }

  "\000" {   return RET(EOI_MARK,Category.CAT_WS);
       }

  "\n"

      {
        s.pos = cursor - firstColumnOn; s.line++;
        if(cursor >= s.lim) 
        {  s.tok = cursor; return RET(EOI_MARK,Category.CAT_WS); }
        continue; 

        // goto normal;

				}


  any

      {

		            System.out.printf("unexpected character: %c\n", s.get(s.tok)); //$NON-NLS-1$
					return RET(OSDLParserTokens.NUM_ID,Category.CAT_UNDEF);
					//continue; // goto normal;

      }

*/



		} // while

	} //method

	NumCat comment() {
        while(true)  {

/*!re2j

  "*/"			{ 
  						this.s.tok = this.long_head;
						this.s.cur = this.cursor;
						return RET(OSDLParserTokens.NUM_COMMENT1, Category.CAT_COMMENT); //goto normal;
                }

  "\n"

      {

						if (this.cursor >= this.s.lim) {
		                    return RET(EOI_MARK,Category.CAT_WS);
						}

						this.s.tok = this.s.pos = this.cursor;
						this.s.pos = this.cursor - firstColumnOn;
						this.s.line++;

                        continue; //comment;

      }

        any			{ 

            continue; //goto comment; 

                 }

*/

		}  //while forever

	} //method

	NumCat oneLineComment() {
        while(true)  {

/*!re2j


  "\n"

      {

						if (this.cursor >= this.s.lim) {
		                    return RET(EOI_MARK,Category.CAT_WS);
						}

						this.s.tok = this.s.pos = this.cursor;
						this.s.pos = this.cursor - firstColumnOn;
						this.s.tok = this.long_head;
						this.s.cur = this.cursor;
						this.s.line++;

                        return RET(OSDLParserTokens.NUM_COMMENT2,Category.CAT_COMMENT); //goto normal; 

      }

        any			{ 

            continue; //goto oneLineComment; 

                 }

*/

		}  //while forever

	} //method




	public void tokenize(ArrayList<Token> result_vec, int m_completion_prefix, String str_input, CursorPos start_pos, CursorPos cursor_pos,

			ITokenIndexResolver tir) {

        // start_pos:  (x,y) coordinate of start of text

        // cursor_pos: (x,y) coordinate of cursor pos (= completion pos)

        //                   (<0,  x) = no code completion

        //                    (0,  0) = complete right before #EOF#

        //                   (>0, >0) = completion position

        // NOTE: We rely on the begin() iterator to find a terminating

        //       \0 char at the end().  If this were not true, we'd have

        //       to add tok_begin+1 < s.end() checks to many if()s below...

        //reset_input();

		XScanner in = this.s = new XScanner(str_input, start_pos.getLine(), start_pos.getColumn());

		result_vec.ensureCapacity(str_input.length() / 3);
        NumCat t = new NumCat(); 
        int line = 0; 

        int column = 0;

		boolean bol = false;

		Category cat = Category.CAT_UNDEF;

	        ErrorState  err_state = ErrorState.Correct;
		while ((t = scan(in)).m_num != EOI_MARK) {
          int num = t.m_num; 
          line = in.line; 

          column = in.tok-in.pos; //in.column; 

          bol = false;
	      cat = t.m_cat;
          int len = in.cur-in.tok;

				String tok_txt = this.s.str.substring(this.s.tok, this.s.tok + len); //US_T(in.tok,len);

				if ( num >= OSDLParserTokens.NUM_ID ) {  

		             // check for reserved keyword

			           // String norm_ident = tok_txt.toUpperCase();
			           String norm_ident = tok_txt; // Case sensitive

						num = tir.getTokenIndex(norm_ident);

						if (num == -1) {

							num = tir.getActualNUMID();

			               cat = Category.CAT_IDENTIFIER;

						} else {

			               cat = Category.CAT_KEYWORD;

			            }

				}

			result_vec.add(new Token((short) num, str_input.substring(in.tok, in.tok + len), // US_T(in.tok,len),

					cat, in.tok - 0, line, column, bol, err_state, (short) 0));

        }
        column = in.tok - in.pos; 
		result_vec.add(new Token(Constants.NUM_EOF, "#EOF#", Category.CAT_WS, str_input.length(), in.line, column, bol, err_state, (short) 0));  //$NON-NLS-1$

      

    }



}

