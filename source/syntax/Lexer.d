module syntax.Lexer;
import syntax.Word;
import syntax.Tokens;
import std.container, std.traits;
import std.stdio, std.file, std.string;

class LexerError : Exception {
    this (string filename) {
	super (filename, " n'est pas un fichier");
    }
}

/**
 Classe de decoupage de fichier par token
 T doit etres un enum
 */
class Lexer {
    
    this (string filename, Token [] skips, Token[2][] comments) {
	this._line = 1;
	this._tokens = [EnumMembers!Tokens];
	foreach (it ; skips) 
	    this._skips[it] = true;
	this._comments = comments;
	this._current = -1;
	this._enableComment = true;
	
	this._filename = filename;
	try {
	    if (filename.isDir)
		throw new LexerError (filename);
	    this._file = File (filename, "r");
	} catch (Throwable o) {
	    throw new LexerError (filename);
	}
    }

    /**
     Le nom du fichier courant
     */
    string filename () const {
	return this._filename;
    }

    /**
     Active un token skip
     Params:
     elem, le token a passe
     on, active ou non     
     */
    void skipEnable (Token elem, bool on = true) {
	this._skips [elem] = on;
    }

    /**
     Active la suppression des commentaire
     Params:
     on, active ou desactive
     */
    void commentEnable (bool on = true) {
	this._enableComment = on;
    }

    /**
     Recupere le mot suivant
     Params:
     word, le mot a retourner par reference
     Return le lexer
     */
    Lexer next (ref Word word) {
	if (this._current >= this._reads.length - 1) {
	    return this.get (word);
	} else {
	    this._current ++;
	    word = this._reads [this._current];
	    return this;
	}
    }

    /**
     Recupere le mot suivant
     Return:
     le mot lu
     */
    Word next () {
	Word word;
	this.next (word);
	return word;
    }
    
    /**
     Retour en arriere dans le fichier
     */
    void rewind (ulong nb = 1) {
	this._current -= nb;
    }
    
    private Lexer get (ref Word word) {
	do {
	    if (!getWord (word)) {
		word.setEof ();
		break;
	    } else {
		Token com;
		if (isComment (word, com) && _enableComment) {
		    do {
			getWord (word);
		    } while (word != com && !word.isEof);
		    getWord (word);
		}
	    }	    
	} while (isSkip (word) && !word.isEof);
	
	this._reads.insertBack (word);	
	this._current ++;
	
	return this;
    }

    private bool isComment (Word elem, ref Token retour) {
	foreach (it ; this._comments) {
	    if (it[0].descr == elem.str) {
		retour = it [1];
		return true;
	    }
	}
	return false;
    }

    private bool isSkip (Word elem) {
	foreach (key, value ; this._skips) {
	    if (key.descr == elem.str && value) return true;
	}
	return false;
    }
    
    private bool getWord (ref Word word) {
	if (this._file.eof ()) return false;
	auto where = this._file.tell ();
	auto line = this._file.readln ();
	if (line is null) return false;
	ulong max = 0, beg = line.length;
	foreach (it ; this._tokens) {
	    auto id = indexOf (line, it.descr);
	    if (id != -1) {
		if (id == beg && it.descr.length > max)  max = it.descr.length;
		else if (id < beg) {
		    beg = id;
		    max = it.descr.length;
		}
	    }
	}
	constructWord (word, beg, max, line, where);
	if (word.str == "\n" || word.str == "\r") {
	    this._line ++;
	    this._column = 1;
	} else {
	    this._column += word.str.length;
	}
	
	return true;
    }

    private ulong min(ulong u1, ulong u2) {
	return u1 < u2 ? u1 : u2;
    }
    
    private void constructWord (ref Word word, ulong beg, ulong _max, string line, ulong where) {	
	if (beg == line.length + 1) word.str = line;
	else if (beg == 0) {
	    word.str = line [0 .. min(_max, line.length)];
	    this._file.seek (where + _max);
	} else if (beg > 0) {
	    word.str = line [0 .. min(beg, line.length)];
	    this._file.seek (where + beg);
	}
	word.locus = Location (this._line, this._column, word.str.length, this._filename);
    }
    
    ~this () {
	this._file.close ();
    }
    
    private Token [] _tokens;
    private bool [Token] _skips;
    private Token [2][] _comments;
    private string _filename;
    private bool _enableComment;
    private Array!(Word) _reads;
    private long _current;
    private File _file;
    private ulong _line;
    private ulong _column;
    
}
