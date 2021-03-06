module ymir.semantic.value.RangeValue;
import ymir.semantic._;
import ymir.ast._;
import ymir.syntax._;
import ymir.lint._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

import std.container;
import std.conv, std.stdio;

class RangeValue : Value {

    private Value  _left;
    private Value _right;
    
    this (Value left, Value right) {
	this._left = left;
	this._right = right;
    }

    override Value BinaryOp (Tokens token, Value right) {
	return null;
    }

    override Value BinaryOpRight (Keys token, Value left) {
	if (!left) return null;
	if (token.id == Keys.IN.id) {
	    if (auto val = cast (BoolValue) this._left.BinaryOp (Tokens.INF, this._right)) {
		if (val.isTrue) {
		    auto leftS = cast (BoolValue) left.BinaryOp (Tokens.SUP_EQUAL, this._left);
		    auto rightI = cast (BoolValue) left.BinaryOp (Tokens.INF, this._right);
		    return leftS.BinaryOp (Tokens.DAND, rightI);		    
		} else {
		    auto leftS = cast (BoolValue) left.BinaryOp (Tokens.INF_EQUAL, this._left);
		    auto rightI = cast (BoolValue) left.BinaryOp (Tokens.SUP, this._right);
		    return leftS.BinaryOp (Tokens.DAND, rightI);		    
		}
	    }
	}
	return null;
    }

    override LInstList toLint (Expression expr) {
	if (COMPILER.isToLint) {
	    auto crange = cast (ConstRange) expr;	
	    auto type = cast (RangeInfo) crange.info.type;
	    Array!LExp params;
	    params.insertBack (new LConstDecimal  (1, LSize.LONG, crange.content.size));
	    auto inst = new LInstList;
	    auto aux = new LReg (crange.info.id, type.size);
	    auto exist = (RangeUtils.__CstName__ in LFrame.preCompiled);
	    if (exist is null) RangeUtils.createCstRange ();
	    inst += new LWrite (aux, new LCall (RangeUtils.__CstName__, params, LSize.LONG));
	    
	    auto left = LVisitor.visitExpressionOutSide (crange.left);
	    auto right = LVisitor.visitExpressionOutSide (crange.right);
	    
	    if (crange.lorr == 1) {
		left = crange.caster.lintInst (left);
	    } else if (crange.lorr == 2) {
		right = crange.caster.lintInst (right);
	    }
	    
	    auto regRead = new LRegRead (aux, new LConstDecimal (2, LSize.INT, LSize.LONG), type.content.size);
	    inst += crange.content.lintInst (new LInstList (regRead), left);
	    regRead = new LRegRead (aux, new LBinop (new LConstDecimal (2, LSize.INT, LSize.LONG),
						 new LConstDecimal (1, LSize.INT, type.content.size), Tokens.PLUS),
				    type.content.size);
	    
	    inst += crange.content.lintInst (new LInstList (regRead), right);
	    inst += aux;			      
	    return inst;
	} else {
	    assert (false, "TODO");
	}
    }

    override Expression toYmir (Symbol sym) {
	auto rng = cast (RangeInfo) sym.type;
	auto left = this._left.toYmir (new Symbol (Word.eof, rng.content.clone ()));
	auto right = this._right.toYmir (new Symbol (Word.eof, rng.content.clone ()));
	auto ret = new ConstRange (Word.eof, left, right);
	ret.info = sym;
	return ret;
    }
    
    Value left () {
	return this._left;
    }

    Value right () {
	return this._right;
    }    

}
