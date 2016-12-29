module ast.Constante;
import ast.Expression, std.stdio;
import syntax.Word, semantic.pack.Symbol, syntax.Keys;
import semantic.types.IntInfo, semantic.types.CharInfo, semantic.types.BoolInfo;
import semantic.types.FloatInfo, semantic.types.StringInfo, semantic.types.PtrInfo;
import std.stdio, std.string, utils.exception, std.conv;
import std.math, std.container, semantic.types.InfoType;
import semantic.types.ArrayInfo, semantic.types.VoidInfo;
import semantic.types.LongInfo, semantic.types.UndefInfo;
import ast.Var;

/**
 Example : 
 ----
 132
 ---
 */
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


/**
 Example :
 ---
 123l
 ---
*/
class Long : Expression {

    this (Word word) {
	super (word);
    }

    override Expression expression () {
	auto aux = new Long (this._token);
	aux.info = new Symbol (this._token, new LongInfo ());
	return aux;
    }

    override void print (int nb = 0) {
	writefln ("%s<Long> %s(%d, %d) %s"
		  , rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);	
    }
}

/**
 Example:
 ---
 'r'
 ---
 */
class Char : Expression {

    private ubyte _code;
    
    this (Word word, ubyte code) {
	super (word);
	this._code = code;
    }
    
    ref ubyte code () {
	return this._code;
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


/**
 Example:
 ---
 12.
 ---
 */
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

/**
 Example:
 ---
 'salut'
 "comment"
 ---
*/
class String : Expression {

    private string _content;    
    private char [string] _escape;
    
    this (Word word, string  content) {
	super (word);
	this._content = content;
	this._escape = ["\\a": '\a', "\\b" : '\b', "\\f" : '\f',
			    "\\n" : '\n', "\\r" : '\r', "\\t" : '\t',
			    "\\v" : '\v', "\\" : '\\',  "\\'" : '\'',
			    "\\\"" : '\"', "\\?": '\?'];   
    }

    private short fromHexa (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
	    if (it >= 'a')
		total += pow (16, size) * (it - 'a');
	    else
		total += pow (16, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    private short fromOctal (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
	    if (it >= 'a')
		total += pow (8, size) * (it - 'a');
	    else
		total += pow (8, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    private short getFromLX (ref string elem, ref ulong index) {
	int size = 0;
	foreach (it ; elem [2 .. $])
	    if ((it < 'a' || it > 'f') && (it < '0' || it > '9'))
		break;
	    else size ++;
	if (size < 1) return -1;
	size = size > 2 ? 2 : size;
	index += size + 2;
	auto escape = elem [2 .. size + 2];
	elem = elem [size + 2 .. $];
	return fromHexa (escape);
    }

    private short getFromOc (ref string elem, ref ulong index) {
	if (elem [1] < '0' || elem [1] > '7') return -1;
	int size = 0;
	foreach (it ; elem [2 .. $])
	    if (it < '0' || it > '7') break;
	    else size ++;
	size = size > 4 ? 4 : size;
	auto escape = elem [1 .. size + 2];
	elem = elem [size + 2 .. $];
	index += size + 1;
	return fromOctal (escape);
    }
    
    
    private short isChar (ref string elem, ref ulong index) {
	if (elem.length == 1) {
	    char c = elem [0];
	    elem = "";
	    return c;
	}
	
	auto val = elem [0 .. 2] in this._escape;
	if (val !is null) {
	    elem = elem [2 .. $];
	    index += 2;
	    return *val; 
	} else if (elem [0] != Keys.ANTI.descr[0]) {
	    char c = elem [0];
	    elem = elem [1 .. $];
	    index += 1;
	    return c;
	} else {
	    if (elem.length > 1) {
		if (elem [1] == Keys.LX.descr [0]) {
		    return getFromLX (elem, index);
		} else {
		    return getFromOc (elem, index);
		}
	    }	    
	}
	return -1;
    }
    
    override Expression expression () {
	ulong index = 0;
	string begin = this._content, end = "";
	while (begin != "") {
	    short s = isChar (begin, index);
	    if (s == -1) throw new UndefinedEscapeChar (this._token, index, begin [0 .. 2]);
	    end ~= to!char (s);
	}
	
	auto aux = new String (this._token, this._content);
	aux._content = end;
	aux.info = new Symbol (this._token, new StringInfo (), true);
	return aux;       
    }

    string content () {
	return this._content;
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
    
    bool value () {
	return this._token.str == "true";
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

