module syntax.Keys;
import syntax.Tokens;
import std.typecons;

enum Keys : Token {
    IMPORT = Token ("import", 1),
    CLASS = Token ("class", 2),
    STRUCT = Token ("struct", 3),
    DEF = Token ("def", 4),
    NEW = Token("new", 5),
    DELETE = Token ("delete", 6),
    IF = Token ("if", 7),
    RETURN = Token ("return", 8),
    FOR = Token ("for", 9),
    FOREACH = Token ("foreach", 10),
    WHILE = Token ("while", 11),
    BREAK = Token ("break", 12),
    THROW = Token ("throw", 13),
    TRY = Token ("try", 14),
    MATCH = Token ("match", 15),
    DEFAULT = Token ("default", 16),
    IN = Token ("in", 17),
    ELSE = Token ("else", 18),
    CATCH = Token ("catch", 19),
    TRUE = Token ("true", 20),
    FALSE = Token ("false", 21),
    NULL = Token ("null", 22),
    CAST = Token ("cast", 23),
    FUNCTION = Token ("fn", 24),
    LET = Token ("let", 25),
    IS = Token ("is", 26),
    NOT_IS = Tokens ("!is", 27),
    ANTI = Token ("\\", 28),
    LX = Token ("x", 29),
    SYSTEM = Token ("system", 30),
    EXTERN = Token ("extern", 31),
    MAIN = Token ("main", 32),
    PUBLIC = Token ("public", 33),
    PRIVATE = Token ("private", 34),
    EXPAND = Token ("expand", 35),
    ENUM = Token ("enum", 36),
    UNDER = Token ("_", 37),
    OPBINARY = Token ("opBinary", 38),
    OPBINARYR = Token ("opBinaryRight", 39),
    ASSERT = Token ("assert", 40),
    STATIC = Token ("static", 41),
    OPACCESS = Token ("opIndex", 42),
    OPRANGE = Token ("opRange", 43),
    OPTEST = Token ("opTest", 44),
    OPUNARY = Token ("opUnary", 45),
    OPEQUAL = Token ("opEquals", 46),
    OPCALL = Token ("opCall", 47),
    TYPEOF = Token ("typeof", 48),
    CONST = Token ("const", 49),
    IMMUTABLE = Token ("imut", 50),
    REF = Token ("ref", 51),
    THIS = Token ("this", 52),
    PROTECTED = Token ("protected", 53),
    MIXIN = Token ("mixin", 54),
    OF = Token ("of", 55)
}
