module ast.Break;
import ast.Instruction, syntax.Word;
import semantic.types.UndefInfo, semantic.pack.Table;
import std.stdio, std.string, utils.exception;
import semantic.types.VoidInfo, semantic.types.InfoType;
import lint.LInstList, std.conv;
import std.container, ast.Var;
import ast.Expression;

/**
 Classe généré par la syntaxe.
 Example:
 ---
 'break' (Identifiant)? ';'
 ---
*/
class Break : Instruction {

    /// L'identifiant de boucle à casser (peut être eof)
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

    /**
     Returns: le nombre de block à remonter
     */
    ulong nbBlock () {
	return this._nbBlock;
    }

    /**
     Vérification sémantique.
     Pour être juste l'instruction doit être dans une scope 'breakable'.
     Si il contient un identifiant, il doit exister.
     Throws: BreakOutSideBreakable, si on n'est pas dans un scope 'breakable'.
     BreakRefUndefined, Si l'indentifiant de boucle n'existe pas.
     */
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

    override Instruction templateReplace (Array!Var names, Array!Expression values) {
	return new Break (this._token);
    }
    
    /**
     Affiche l'instruction sous forme d'arbre.
     Params:
     nb = 'loffset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Break> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);		  
		  
    }
    
}
