module ast.Return;
import ast.Instruction;
import ast.Expression, syntax.Word;
import semantic.types.UndefInfo, semantic.pack.Table;
import std.stdio, std.string, utils.exception;
import semantic.types.VoidInfo, semantic.types.InfoType;
import lint.LInstList;

class Return : Instruction {

    private Expression _elem;
    private InstCompS _instComp;
    
    this (Word word) {
	super (word);
    }
    
    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }

    override Instruction instruction () {
	auto aux = new Return (this._token);
	if (this._elem !is null) {
	    aux._elem = this._elem.expression ();
	    this._instComp = aux._elem.info.type.ReturnOp ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = aux._elem.info.type.clone ();
	    }
	} else {
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) is null &&
		cast(VoidInfo) (Table.instance.retInfo.info.type) is null) {
		throw new NoValueNonVoidFunction (this._token);
	    } else {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }
	}
	return aux;
    }
    
    Expression elem () {
	return this._elem;
    }
    
    InstCompS instComp () {
	return this._instComp;
    }

    LInstList instComp (LInstList llist) {
	return this._instComp (llist);
    }

    override void print (int nb = 0) {
	writefln ("%s<Return> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	if (this._elem !is null) {
	    this._elem.print (nb + 4);
	}
    }
    
}
