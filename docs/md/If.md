# If

<hr>


`if` est un mot clé qui permet de générer un branchement.

```Rust
let x = 5;
if x == 5 {
	println ("X is ", x);
}

```

La valeur de `x == 5` est comparé avec un type `bool`. Si aucun `cast` implicite n'est possible une erreur est lancé.

```Rust 
if "salut" { // Erreur, type incompatible bool et string.
}

if 1 { // Ok, 1 != 0
	println ("ici");
}

```

`else` permet de récuperer les cas non gérer par le `if`.

```Rust
if 0 {
	println ("Le langage est cassé");
} else {
	println ("Ça à l'air de fonctionner");
}

if 0 {
	//	...
} else if 1 == 1 {
	println ("La aussi");
}

```

## Match
<hr>



Parfois il existe de nombreuse valeurs possible à traiter dans un `if`. Pour permettre une meilleur lisibilité, il existe en Ymir, le mot clé `match`. Celui-ci vérifie plusieurs possibilité de valeur et applique celle qui correspond.

```Rust
let x = 3;
match x {
	1 => println ("un");
	2 => { x += 1; println ("deux"); }
	3 => println ("trois");
	_ => assert (false, "Valeur inconnu");
}

```


## Expression Match
<hr>


Il est possible d'utiliser l'instruction `match` comme un expression. 

```Rust 
def foo (a) {
	return match a {
		1 => "salut";
		_ => "Non";
	};
}

println (foo (1)); // Ok, "salut"
println (foo ('y')); // Ok, "Non"

```









