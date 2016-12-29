module ast.Break;
import ast.Instruction, syntax.Word;
import semantic.types.UndefInfo, semantic.pack.Table;
import std.stdio, std.string, utils.exception;
import semantic.types.VoidInfo, semantic.types.InfoType;
import lint.LInstList, std.conv;

/**
 Classe généré par la syntaxe : 'break' exp? ';'
*/
class Break : Instruction {

    private Word _id;
    
    /// le nombre de block a remonter
    private ulong _nbBlock; 
    
    this (Word token) {
	super (token);
	this._id.setEof ();
    }
    
    this (Word token, Word id) {
	super (token);
	this._id = id;
    }

    ulong nbBlock () {
	return this._nbBlock;
    }

    /// Vérification sémantique
    override Instruction instruction () {
	auto aux = new Break (this._token);
	Table.instance.retInfo.breaked ();
	if (this._id.isEof ()) {
	    auto nb = Table.instance.retInfo.rewind (["while", "for"]);
	    if (nb == -1) {
		throw new BreakOutSideBreakable (this._token);
	    } else
		aux._nbBlock = to!ulong (nb);
	} else {
	    auto nb = Table.instance.retInfo.rewind (this._id.str);
	    if (nb == -1) throw new BreakRefUndefined (this._id, this._id.str);
	    else aux._nbBlock = to!ulong (nb);
	}
	return aux;
    }

    override void print (int nb = 0) {
	writefln ("%s<Break> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);		  
		  
    }
    
}
