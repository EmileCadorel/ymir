module semantic.pack.FrameScope;
import semantic.pack.Scope, semantic.pack.Symbol;
import semantic.types.InfoType, utils.exception;
import std.container, std.outbuffer, std.string;
import std.stdio, syntax.Word, std.algorithm;


class TreeInfo {

    private string _name;
    private Word _ident;
    private Array!TreeInfo _infos;
    private bool _returned = false;
    private bool _breaked = false;
    private TreeInfo _father;

    this (string name) {
	this._name = name;
    }

    Word ident () {
	return this._ident;
    }

    Word exist (string name) {
	if (this._ident.str == name) return this._ident;
	else if (this._father) return this._father.exist (name);
	else return Word.eof;
    }
    
    void ident (Word name) {
	auto ex = this.exist (name.str);
	if (!ex.isEof ()) throw new MultipleLoopName (name, ex);
	this._ident = name;
    }

    void returned () {
	this._returned = true;
    }    

    void breaked () {
	this._breaked = true;
    }    
    
    string name () {
	return this._name;
    }
    
    TreeInfo enterBlock (string sc) {
	this._infos.insertBack (new TreeInfo (sc));
	this._infos.back._father = this;
	return this._infos.back;
    }

    bool hasBreaked () {
	if (this._infos.length == 0) return this._breaked;
	ulong nb = 0;
	string need = "";
	bool allNeed = true;
	foreach (it ; this._infos) {
	    if (!allNeed && need == it._name) allNeed = true;
	    if (it._breaked && it._name == "true") {
		this._breaked = true;
		return true;
	    } else if (it._breaked && it._name == "else") {
		nb ++;
	    } else if (it._breaked && it._name == "if") {
		nb ++;
		allNeed = false;
		need = "else";
	    } else if (it._breaked && it._name != "while" && it._name != "for") {
		nb ++;
	    }
	}
	
	if (nb == this._infos.length && allNeed) {
	    this._breaked = true;
	}
	return this._breaked;    
    }
    
    bool hasReturned () {
	if (this._infos.length == 0) return this._returned;
	ulong nb = 0;
	string need = "";
	bool allNeed = true;
	foreach (it ; this._infos) {
	    if (!allNeed && need == it._name) allNeed = true;
	    if (it._returned && it._name == "true") {
		this._returned = true;
		return true;
	    } else if (it._returned && it._name == "else") {
		nb ++;
	    } else if (it._returned && it._name == "if") {
		nb ++;
		allNeed = false;
		need = "else";
	    } else if (it._returned && it._name != "while" && it._name != "for") {
		nb ++;
	    }
	}
	
	if (nb == this._infos.length && allNeed) {
	    this._returned = true;
	}
	return this._returned;
    }
    
    TreeInfo quitBlock () {
	hasBreaked ();
	hasReturned ();
	return this._father;
    }

    bool retract () {
	if (this._infos.length == 0) {
	    if (this._father !is null) return this._father.retract ();
	    else return this._returned;
	}	
	hasReturned ();
	if (this._father)
	    return this._father.retract;
	else return this._returned;
    }
        
    long rewind (string name, long nb = 0) {
	nb ++;
	if (this._ident.str == name) {
	    return nb;
	} else if (this._father) {
	    return this._father.rewind (name, nb);
	} else return -1;
    }

    long rewind (string [] types, long nb = 0) {	
	nb ++;
	if (find(types, this._name) != []) return nb;
	else if (this._father) return this._father.rewind (types, nb);
	else return -1;
    }
    
    void print (int i = 0) {
	auto buf = new OutBuffer ();
	if (this._returned) 
	    writefln ("%s%s, %s {:true", rightJustify("", i, ' '),
		      this._name, this._ident.str);
	else
	    writefln ("%s%s, %s {", rightJustify("", i, ' '),
		      this._name, this._ident.str);
	
	foreach (it ; this._infos) {
	    it.print (i + 4);
	}
	writefln ("%s}", rightJustify ("", i, ' '));
    }
        
}

struct FrameReturnInfo {
    
    Symbol info;        
    private string _currentBlock;
    private TreeInfo _retInfo = null;
    
    
    static ref FrameReturnInfo empty () {
	return _empty;
    }

    void returned () {
	this._retInfo.returned;
    }    

    void breaked () {
	this._retInfo.breaked ();
    }
    
    void enterBlock () {
	if (this._retInfo)
	    this._retInfo = this._retInfo.enterBlock (this._currentBlock);
	else this._retInfo = new TreeInfo (this._currentBlock);
    }
       
    void quitBlock () {
	this._retInfo = this._retInfo.quitBlock ();
	if (this._retInfo)
	    this._currentBlock = this._retInfo.name;
    }

    bool retract () {
	return this._retInfo.retract ();
    }
    
    bool hasReturned () {
	return this._retInfo.hasReturned ();
    }

    bool hasBreaked () {
	return this._retInfo.hasBreaked ();
    }    
    
    void setIdent (Word ident) {
	this._retInfo.ident = ident;
    }    
    
    ref string currentBlock () {
	return this._currentBlock;
    }   

    long rewind (string name) {
	return this._retInfo.rewind (name);
    }

    long rewind (string [] types) {
	return this._retInfo.rewind (types);
    }
    
    void print () {
	this._retInfo.print ();
    }

    static FrameReturnInfo _empty;
}


class FrameScope {


    private FrameReturnInfo _retInfo;
    private SList!Scope _local;
    private string _namespace;

    this (string namespace) {
	this._retInfo.currentBlock = "";
	this._namespace = namespace;
	this.enterBlock ();
    }

    ~this () {
    }
    
    void enterBlock () {
	this._local.insertFront (new Scope ());
	this._retInfo.enterBlock ();
    }

    Array!Symbol quitBlock () {
	this._retInfo.quitBlock ();
	if (!this._local.empty) {
	    auto ret = this._local.front ().quit (this._namespace);
	    this._local.removeFront ();
	    return ret;
	}
	return make!(Array!Symbol);
    }

    void insert (string name, Symbol info) {
	this._local.front [name] = info;
    }

    void garbage (Symbol info) {
	if (!this._local.empty)
	    this._local.front.garbage (info);
    }
    
    Symbol opIndex (string name) {
	foreach (it ; this._local) {
	    auto t = it [name];
	    if (t !is null) return t;
	}
	return null;
    }

    ref string namespace () {
	return this._namespace;
    }
    
    ref FrameReturnInfo retInfo () {
	return this._retInfo;
    }
    
}
