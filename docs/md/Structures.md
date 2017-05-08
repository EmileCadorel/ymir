# Structure 
<hr>

Les Structures permettent de créer de nouveaux types. Leurs instances sont allouées dynamiquement et récupérées par le garbage collector.

<br>
```D
struct 
| f : float
| tab : [int]
-> B;
```

<br>
Et on les instancie :

```D
let a = A (10), b = B (.1, []);
let b2 = b; // b2 est une reference vers b, aucune recopie n'est faite.

```
<br>
Les construction doivent se faire avec tout les paramètres ou aucun.

<br>
L'accès au paramètre se fait avec l'opérateur `.`

```D
print (a.i);
print (b.f);
print (b.s); // Erreur, la structure B(float) n'a pas d'attribut 's'
b.tab += [10];
```

<br>
## Appel
----------

Les attributs des structures sont passés par référence
```D

struct (attr : int) A;

def foo (a : A) {
    a.attr = 123; // les attributs de a sont passé par références
    a = A (2); // a ne sera pas changé en sortie de fonction
}

// ...
let a = A (0);
foo (a);
println (a.attr); // 123
```

<br>
## Structure privée
---------------------

 Il est possible de déclarer des structures dans des blocs, elles deviennent privées à ce bloc.

 ```D
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

<br>
## Structure templates
<hr>

On peut déclarer et instancié des structures ayant des paramètre templates.
```D

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
<br>

Contrairement au fonction, on ne peut pas spécialiser les templates des structures avec des constantes.





