module ymir.utils.Matching;
import std.traits;

T match (T, Elem) (Elem e) if (is (T : Elem)) {
    return cast (T) e;
}

void match (U, T...) (U inst, T funcs) {
    import std.traits;
    foreach (func ; funcs) {
	static assert (ParameterTypeTuple!(func).length == 1);
	alias tuple = ParameterTypeTuple!(func) [0];
	if (auto tu = cast (tuple) inst) {
	    func (tu); return; 
	}
    }
    assert (false, "TODO " ~ typeid (inst).toString);
}

auto matchRet (U, T...) (U inst, T funcs) {
    import std.traits;
    foreach (func ; funcs) {
	static assert (ParameterTypeTuple!(func).length == 1);
	alias tuple = ParameterTypeTuple!(func) [0];
	if (auto tu = cast (tuple) inst) {
	    return func (tu); 
	}
    }
    assert (false, "TODO " ~ typeid (inst).toString);    
}
