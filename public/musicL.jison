%{
	var tiempo = 0;
	var tiempo_temp = 0;
%}

%token REDONDA BLANCA NEGRA DOBLE_BARRA BARRA 

//Precedencia:

%start partitura

%% /* Lenguaje */
partitura
    : CLAVE ARMADURA guardar_ritmo compases EOF
	  {	
		return [{clave: $1, armadura: $2, ritmo: $3, cuerpo: $4}];
	  }
    ;

guardar_ritmo
    : RITMO
	{
		var derecha = $1.substr(0,$1.indexOf("\/"));
		var izquierda = $1.substr($1.indexOf("\/")+1,$1.length);
		
		//Transformamos el ritmo en tiempo, facilitando el cáclculo. 
		if(izquierda == 4)
		    tiempo = 1*derecha;
		else if(izquierda == 2)
		    tiempo = 2*derecha;
		else if(izquierda == 1)
		    tiempo = 4*derecha;
		    
		$$ = $1;
	}
    ;

compases
    : compas DOBLE_BARRA
	{
		$$ = $1;
	}
     | compas BARRA compases
	{
		
		if($1) $$ = [$1];
		
		if($3) $$ = $$.concat($3);

	}
     ;
compas 
	: reset_time notas
	{
		$$ = {type: 'Compas', notas: $2}
	}
	;
	
reset_time
	: 
	{
	  tiempo_temp = 0;
	}
	;
	

notas
	: nota notas
	{
		if($2) $$ = $$.concat($2); 
	}
	| /*vacio */
	{
		$$ = [];
	}
	;

nota
	: NOM_NOTA alteracion figura
	{
		if(tiempo_temp > tiempo)
		   throw new Error("Se sobrepasa el ritmo del compás con la nota: " + $NOM_NOTA + $figura.valor );
		if($2 != undefined)
		  $$ = [{type: 'Nota', nombre: $1.concat($2), figura: $3}];
		else
		  $$ = [{type: 'Nota', nombre: $1, figura: $3}];
	}
	| SILENCIO figura
	{
		if(tiempo_temp > tiempo)
		  throw new Error("Se sobrepasa el ritmo del compás con el silencio: " + $SILENCIO + $figura.valor );
		else
		  $$ = [{type: 'Silencio', figura: $2}];
	}
	;
	
alteracion
	: ALTERACION
	| /* vacio */
	;

figura 
        : REDONDA 
	{
		tiempo_temp = tiempo_temp +4;
		$$ = {nombre: 'Redonda', valor: $1};
	}
	| BLANCA
	{	
		tiempo_temp = tiempo_temp +2;
		$$ = {nombre: 'Blanca', valor: $1};
	}
	| NEGRA
	{
 		tiempo_temp ++;
 		$$ = {nombre: 'Negra', valor: $1};
	}
	;
