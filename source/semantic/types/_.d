module semantic.types._;

public import semantic.types.ArrayInfo;
public import semantic.types.BoolInfo;
public import semantic.types.CharInfo;
public import semantic.types.DecimalInfo;
public import semantic.types.EnumInfo;
public import semantic.types.FloatInfo;
public import semantic.types.FunctionInfo;
public import semantic.types.InfoType;
public import semantic.types.NullInfo;
public import semantic.types.PtrFuncInfo;
public import semantic.types.RangeInfo;
public import semantic.types.RefInfo;
public import semantic.types.StringInfo;
public import semantic.types.StructInfo;
public import semantic.types.TupleInfo;
public import semantic.types.PtrInfo;
public import semantic.types.UndefInfo;
public import semantic.types.VoidInfo;
public import semantic.types.StaticArrayInfo;

public import semantic.types.ArrayUtils;
public import semantic.types.BoolUtils;
public import semantic.types.CharUtils;
public import semantic.types.DecimalUtils;
public import semantic.types.EnumUtils;
public import semantic.types.FloatUtils;
public import semantic.types.PtrFuncUtils;
public import semantic.types.RangeUtils;
public import semantic.types.RefUtils;
public import semantic.types.StringUtils;
public import semantic.types.StructUtils;
public import semantic.types.TupleUtils;
public import semantic.types.ClassUtils;

T match (T : InfoType, T2 : InfoType) (T2 info, bool left = false) {
    if (info is null) return null;
    if (auto same = cast (T) info) return cast (T) same.clone ();
    if (auto _ref = cast (RefInfo) info) {
	if (auto same = cast (T) _ref.content) {
	    same = cast (T) same.clone ();
	    _ref.addUnrefRight (same);
	    return same;
	}
    }
    return null;
}

