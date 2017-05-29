# Mixin
<hr>

Le mot clé `mixin` permet de compiler un élément de type string en du code fonctionnel.
L'élément doit être `immutable`.

```Rust

def foo (op : string) (a, b) {
	return mixin ("a " + op + " b");
}

// ...
let a = foo!"+" (1, 2);
assert (a == 3);
```


Il existe deux cas de `mixin`:
- Le mot clé est utilisé pour déclarer une instruction
- Il est utilisé dans une expression.


```Rust
let a = mixin "1 + 2"; // Utilisation comme expression.

mixin ("
	import std.string;
	
	def foo (a : string) {
		return a + "foo";
	}
	
	return foo ('test');
"); // Utilisation comme instruction

```



Tous les élément déclarer dans le `mixin` ne peuvent en sortir, l'exemple précédent revient à écrire:

```Rust
	let a = 1 + 2; 

	{
		import std.string;
	
		def foo (a : string) {
			return a + "foo";
		}
	
		return foo ('test');
	} 
	
```


Pour garder la coloration syntaxique, il existe une jeton pour définir une `string`: `({` `})`

Il est donc possible d'écrire un mixin de la façon suivante:

```Rust
let a = mixin ({ a + b * 10 / 34 });

mixin ({
	let a = 10;
	println (a);
	return 123;
});

```



