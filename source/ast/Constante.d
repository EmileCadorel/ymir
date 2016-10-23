module ast.Constante;
import ast.Expression;
import syntax.Word;
import std.stdio, std.string;

class Int : Expression {
    this (Word word) {
	super (word);
    }

    override void print (int nb = 0) {
	writefln ("%s<Int> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);	
    }
    
}

class Char : Expression {

    private short _code;
    
    this (Word word, short code) {
	super (word);
	this._code = code;
    }

    override void print (int nb = 0) {
	writefln ("%s<Char> %s(%d, %d) %d"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._code);	
   } 
    
}

class Float : Expression {
    
    private string _suite;
    
    this (Word word, string suite) {
	super (word);
	this._suite = suite;
    }
    
    this (Word word) {
	super (word);
    }

    override void print (int nb = 0) {
	if (this._suite !is null) {
	    writefln ("%s<Float> %s(%d, %d) %s.%s"
		      , rightJustify ("", nb, ' '),
		      this._token.locus.file,
		      this._token.locus.line,
		      this._token.locus.column,
		      this._token.str,
		      this._suite);
	} else {
	    writefln ("%s<Float> %s(%d, %d) 0.%s"
		      , rightJustify ("", nb, ' '),
		      this._token.locus.file,
		      this._token.locus.line,
		      this._token.locus.column,
		      this._token.str);
	}
   }
    
}

class String : Expression {

    private string _content;

    this (Word word, string  content) {
	super (word);
	this._content = content;
    }

    override void print (int nb = 0) {
	writefln ("%s<String> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._content);
    }
    
}

class Bool : Expression {
    this (Word word) {
	super (word);
    }

    override void print (int nb = 0) {
	writefln ("%s<Bool> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
    }

    
}

class Null : Expression {
    this (Word word) {
	super (word);
    }

    override void print (int nb = 0) {
	writefln ("%s<Null> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
    }
    
}
