# Structure 
<hr>

Les Structures permettent de créer de nouveaux types. Leurs instances sont allouées dynamiquement et récupérées par le garbage collector.


```Rust

struct A {
	a : int, 
	b : float
}

struct 
| f : float
| tab : [int]
-> B;
```


Et on les instancie :

```Rust
let a = A (10, 3.), b = B (.1, []);
let b2 = b; // b2 est une reference vers b, aucune recopie n'est faite.

```

Les construction doivent se faire avec tout les paramètres ou aucun.


L'accès au paramètre se fait avec l'opérateur `.`

```Rust
print (a.i);
print (b.f);
print (b.s); // Erreur, la structure B(float) n'a pas d'attribut 's'
b.tab += [10];
```


## Appel
----------

Les attributs des structures sont passés par référence
```Rust
struct 
| attr : int 
-> A;

def foo (a : A) {
    a.attr = 123; // les attributs de a sont passé par références
    a = A (2); // a ne sera pas changé en sortie de fonction
}

// ...
let a = A (0);
foo (a);
println (a.attr); // 123
```


## Structure privée
---------------------

 Il est possible de déclarer des structures dans des blocs, elles deviennent privées à ce bloc.

 ```Rust
 def test () {}
 def foo () {
     {
        struct 
		| a : int 
		-> C;
		
        struct 
		| a : int 
		| f : float 
		-> test; // Erreur, 'test' existe déjà, c'est une fonction
		
        let a = C (123); // Ok, a est de type 'C'
     }
     let c = C (10); // Erreur, 'C' n'existe pas
 }
 ```


## Structure templates
<hr>

On peut déclarer et instancier des structures ayant des paramètres templates.
```Rust
struct (K, V)
| key : K
| value : V
| left : Entry !(K, V)
| right : Entry !(K, V)
-> Entry;

// ...

let a = Entry (10); // Erreur
let b = Entry !(int, string) (1, "salut", null, null); // Ok
let c = Entry !(int, string) (); // Ok
let d = Entry !("salut", string) (); // Erreur
```


Contrairement au fonction, on ne peut pas spécialiser les templates des structures avec des constantes.





