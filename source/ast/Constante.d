module ast.Constante;
import ast.Expression;
import syntax.Word, semantic.pack.Symbol;
import semantic.types.IntInfo, semantic.types.CharInfo, semantic.types.BoolInfo;
import semantic.types.FloatInfo, semantic.types.StringInfo, semantic.types.PtrInfo;
import std.stdio, std.string;

class Int : Expression {
    this (Word word) {
	super (word);
    }
    
    override Expression expression () {
	auto aux = new Int (this._token);
	aux.info = new Symbol (this._token, new IntInfo ());
	aux.info.isConst = true;
	return aux;
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

    override Expression expression () {
	auto aux = new Char (this._token, this._code);
	aux.info = new Symbol (this._token, new CharInfo (), true);
	return aux;
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
    private string _totale;
    
    this (Word word, string suite) {
	super (word);
	this._suite = suite;
	this._totale = this._token.str ~ "." ~ this._suite;
    }
    
    this (Word word) {
	super (word);
	this._totale = "." ~ this._token.str;
    }

    this (string totale, Word word) {
	super (word);
	this._totale = totale;
    }
    
    override Expression expression () {
	auto aux = new Float (this._totale, this._token);
	aux.info = new Symbol (this._token, new FloatInfo (), true);
	return aux;
    }
    
    string totale () const {
	return this._totale;
    }

    override void print (int nb = 0) {
	writefln ("%s<Float> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._totale);
	
   }
    
}

class String : Expression {

    private string _content;

    this (Word word, string  content) {
	super (word);
	this._content = content;
    }

    override Expression expression () {
	auto aux = new String (this._token, this._content);
	aux.info = new Symbol (this._token, new StringInfo (), true);
	return aux;
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

    override Expression expression () {
	auto aux = new Bool (this._token);
	aux.info = new Symbol (this._token, new BoolInfo (), true);
	return aux;
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

    override Expression expression () {
	auto aux = new Null (this._token);
	aux.info = new Symbol (this._token, new PtrInfo (), true);
	return aux;
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
