module ymir.semantic.types.Creators;
import ymir.utils.Singleton;
import ymir.ast.Expression;
import ymir.syntax.Word;
import ymir.semantic.types._;

alias CREATORS = Creators.instance;

class Creators {

    /** La liste des types que l'on peut créé grâce à leurs nom */
    InfoType function (Word, Expression[]) [string] _creators;

    this () {
	this._creators = ["int" : &DecimalInfo.create,
		    "uint" : &DecimalInfo.create,
		    "short" : &DecimalInfo.create,
		    "ushort" : &DecimalInfo.create,
		    "byte" : &DecimalInfo.create,
		    "ubyte" : &DecimalInfo.create,
		    "long" : &DecimalInfo.create,
		    "ulong" : &DecimalInfo.create,
		    "bool" : &BoolInfo.create,
		    "string" : &StringInfo.create,
		    "float" : &FloatInfo.create,
		    "char" : &CharInfo.create,
		    "void" : &VoidInfo.create,
		    "p" : &PtrInfo.create,
		    "array" : &ArrayInfo.create,
		    "fn" : &PtrFuncInfo.create,
		    "ref" : &RefInfo.create,
		    "r" : &RangeInfo.create,
		    "t" : &TupleInfo.create];
    }    

    
    ref auto elems () {
	return this._creators;
    }


    mixin Singleton;

}
