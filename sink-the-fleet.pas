{$mode objfpc}{$H-}{$R+}{$T+}{$Q+}{$V+}{$D+}{$X-}{$warnings on}

program barcos;

const
		
	MaxNBarcosS = 15;	// Maximo numero de barcos Submarino 
	MaxNBarcosF = 3;	// Maximo numero de barcos Fragata 
	MaxNBarcosP = 2;	// Maximo numero de barcos Portaaviones 
	
	MaxFilas = 'J';
	MaxColumnas = 10;
	
	MaxNJugs = 2;		// Maximo numero de jugadores.
	
	MaxNBarcos = 20;	// Maximo numero de barcos por Jugador
	MaxNMovs = 20;
	MaxNLong = 3;
	
	LongPal = 50;
	Tab: char = '	';
		
type
	TipoPal = record
	
		cars: string[LongPal];
		ncars: integer;
	end;
	
	TipoEstado = (Agua, Tocado, Hundido);	
	
	TipoClase = (Submarino, Fragata, Portaaviones, FIN);
	TipoFila = 'A'..MaxFilas;
	TipoColumna = 1..MaxColumnas;
	TipoCasilla = record
	
		fila: TipoFila;
		columna: TipoColumna;
		estado: TipoEstado;
	end;
	DatosCasillas = array [1..MaxNLong] of TipoCasilla;
	TipoOrientacion = (Horizontal, Vertical);
	
	TipoBarco = record
	
		clase: TipoClase;
		casillas: DatosCasillas;
		orientacion: TipoOrientacion;
		longitud: integer;
	end;
	
	DatosBarcos = array [1..MaxNBarcos] of TipoBarco;
	
	TipoFlota = record						
	
		barcos : DatosBarcos;				
		nbarcos: integer;
		nbarcosS: integer;
		nbarcosF: integer;
		nbarcosP: integer;
	end;								
	
	TipoMovimiento = record
	
		casilla: TipoCasilla;
		estado: TipoEstado;	
	end;
	
	DatosMovimientos = array [1..MaxNMovs] of TipoMovimiento;
	
	TipoJugada = record				
	
		movs: DatosMovimientos;
		nmovs: integer;
	end;
	
	TipoTablero = array [TipoFila, TipoColumna] of char;
	
	TipoJugador = record
	
		flota: TipoFlota;
		jugada: TipoJugada;
		tablero: TipoTablero;
	end;

	TipoJuego = array [1..MaxNJugs] of TipoJugador;
	TipoGanador = record
	
		lohay: boolean;
		quien: integer;
	end;
	
procedure indiceColumnas();
var
	c: integer;
begin
	for c:= 1 to MaxColumnas do begin

		write(c, ' ');			// Escribe el numero de las columnas (debajo)
	end;
	writeln();	
end;

procedure longitud(var b: TipoBarco);
begin
	if b.clase = Submarino then
	
		b.longitud:= 1
	else if b.clase = Fragata then
	
		b.longitud:= 2
	else if b.clase = Portaaviones then
	
		b.longitud:= 3
	else 
		
		b.longitud:= 0
end;

procedure fatal(msg: string);
begin

	writeln('Error fatal: ', msg);
	halt(1);
end;

procedure vacialPal(var pal: TipoPal);
begin

	pal.ncars := 0;
end;

procedure appCar(var pal: TipoPal; c: char);
begin

	if pal.ncars = LongPal then begin
	
		fatal('Has superado el limite de caracteres');
	end;
	
	pal.ncars := pal.ncars + 1;
	pal.cars[pal.ncars] := c;
end;

function esBlanco(c: char): boolean;
begin

	result := (c = ' ') or (c = Tab);
end;


procedure leerPal(var entrada: Text; var pal: TipoPal);
var
	c: char;
	haypalabra: boolean;
begin
	vacialPal(pal);
	haypalabra := False;

	repeat
		if eoln(entrada) then begin
		
			readln(entrada);
		end
		else begin
		
			read(entrada, c);
			
			if not esBlanco(c) then begin
			
				haypalabra := True;
			end;
		end;
		
	until eof(entrada) or haypalabra;

	while haypalabra do begin
		
		appCar(pal, c);
		
		if eof(entrada) or eoln(entrada) then begin
		
			haypalabra := False;
		end
		else begin
		
			read(entrada, c);
			haypalabra := not esBlanco(c);
		end;
	end;
end;

function palAcadena(pal: TipoPal): string;
var
	i: integer;
	s: string;
	
begin
	setlength(s, pal.ncars);
	for i := 1 to pal.ncars do begin
		s[i] := pal.cars[i];
	end;
	result := s;
end;

procedure leerCadena(var entrada: text; var s: string);
var 
	pal: TipoPal;
	
begin
	leerPal(entrada, pal);
	s := palAcadena(pal);
end;

procedure leerClase(var entrada: text; var clase: TipoClase; var esfin: boolean; var ok: boolean);
var
	s: string;
	pos: integer;
begin
	esfin:= False;
	leerCadena(entrada, s);
		
	val(s, clase, pos);
	if clase = Submarino then
	
		clase:= Fragata
	else 
	esfin:= clase = FIN;
	ok:= pos = 0;	
end;

procedure leerFila(var entrada: text; var fil: TipoFila; var ok: boolean);
var
	s: string;
begin	
	ok:= False;
	leerCadena(entrada, s);
	if (length(s) = 1) and (s[1] >= 'A') and (s[1] <= 'J') then begin
	
		fil:= s[1];
		ok:= True;
	end
end;

procedure leerColumna(var entrada: text; var col: TipoColumna; var ok: boolean);
var
	s: string;
	pos: integer;
begin
	leerCadena(entrada, s);
	val(s, col, pos);
	ok:= pos = 0;		
end;

procedure leerCasilla(var entrada: text; var casillas: DatosCasillas; var ok: boolean);
begin
	if ok then

		leerfila(entrada, casillas[1].fila, ok);
	
	if ok then
	
		leerColumna(entrada, casillas[1].columna, ok);
end;
		
procedure leerOrientacion(var entrada: text; var orientacion: TipoOrientacion; var ok: boolean);
var
	s: string;
	pos: integer;
begin
	if ok then begin
	
		leerCadena(entrada, s);
		val(s, orientacion, pos);
		ok:= pos = 0;	
	end;
end;	

procedure leerBarco(var entrada: text; var b: TipoBarco; var esfin: boolean; var ok: boolean);
begin
	leerClase(entrada, b.clase, esfin, ok);
	longitud(b);
	if (not esfin) then begin 
			
		leerCasilla(entrada, b.casillas, ok);	
		leerOrientacion(entrada, b.orientacion, ok);
	end;
end;

procedure barcoValido(var f: TipoFlota; b: TipoBarco; var limite: boolean);
begin
	limite:= False;
	if (b.clase = Submarino) then begin
		
		f.nbarcosS:= F.nbarcosS + 1;
		if (f.nbarcosS > MaxNBarcosS) then 
		
			limite:= True;
	end
	else if (b.clase = Fragata) then  begin
		
		f.nbarcosF:= F.nbarcosF + 1;
		if (f.nbarcosF > MaxNBarcosF) then 
		
			limite:= True;
	end
	else if (b.clase = Portaaviones) then begin
		
		f.nbarcosP:= F.nbarcosP + 1;
		if (f.nbarcosP > MaxNBarcosP) then 
			limite:= True;
	end;
end;

procedure leerFlota(var entrada: text; var flota: TipoFlota; var ok: boolean);
var
	esfin: boolean;
	limite: boolean;
	i: integer;
	b: TipoBarco;
begin
	i:= 1;
	flota.nbarcos:= 0;
	flota.nbarcosS:= 0;
	flota.nbarcosF:= 0;
	flota.nbarcosP:= 0;
	repeat
		
		leerBarco(entrada, b, esfin, ok);
		barcoValido(flota, b, limite);
		if (not esfin) and (ok) then begin
			
			if (not limite) then begin
			
				flota.barcos[i]:= b;
				flota.nbarcos:= flota.nbarcos + 1;
			end
			else
				writeln('Has superato el limite de barcos del tipo ', b.clase);
			i:= i + 1;
		end;	
	until (esfin) or (not ok) or (i > MaxNBarcos);
	
	if (i > MaxNBarcos) then
		
		fatal('Has superado el limite de barcos');
	if (not ok) then 
		
		fatal('Entrada de barcos erronea');
end;

function diferencia(b: TipoBarco; casilla: TipoCasilla): integer;
var
	proa: TipoCasilla;
begin
	proa:= b.casillas[1];
	if (b.orientacion = Horizontal) then 
	
		result:= casilla.columna - proa.columna
	else	// Vertical
	
		result:= ord(casilla.fila) - ord(proa.fila)
end;

procedure encontrarCasilla(var b: TipoBarco; var casilla: TipoCasilla; var encontrado: boolean; var i: integer);
begin
	// Posicion --> Fila / Columna
	if (diferencia(b, casilla) < (b.longitud)) and	// Diferencia entre posicion actual y del barco menor que longitud
		(diferencia(b, casilla) > 0) then begin		// Diferencia entre posicion actual y del barco mayor que 0 (positivo)

		b.casillas[diferencia(b, casilla) + 1]:= casilla;
		encontrado:= True;
	end
	else begin
	
		i:= i + 1;
	end;
end;

procedure buscarCasilla(var flota: TipoFlota; var casilla: TipoCasilla);
var
	b: TipoBarco;
	proa: TipoCasilla;
	i: integer;
	encontrado: boolean;

begin
	encontrado:= False;
	i:= 1;
	while (i <= flota.nbarcos) and (not encontrado) do begin
		
		b:= flota.barcos[i];
		proa:= b.casillas[1];
		if (b.orientacion = Horizontal) 
			and (casilla.fila = proa.fila) then begin
			
			encontrarCasilla(flota.barcos[i], casilla, encontrado, i);
		end
		else if (b.orientacion = Vertical) 
			and (casilla.columna = proa.columna) then begin

			encontrarCasilla(flota.barcos[i], casilla, encontrado, i);
		end
		else begin
		
			i:= i + 1;
		end;
	end;
end;

procedure asignarFlota (var flota: TipoFlota);	
var
	casilla: TipoCasilla;
	f: char;
	c: integer;
begin
	for f:= 'A' to MaxFilas do begin		// Recorro el tablero para buscar las casillas correspondientes
		for c:= 1 to MaxColumnas do begin		// a los barcos, y asignarselos
		
			casilla.fila:= f;
			casilla.columna:= c;
			buscarCasilla(flota, casilla);
		end;
	end;
end;

procedure leerJuego(var entrada: text; var juego: TipoJuego);
var
	i: integer;
	ok: boolean;
begin
	for i:= 1 to MaxNJugs do begin
		
		leerFlota(entrada, juego[i].flota, ok);
		asignarFlota(juego[i].flota);		
	end
end;

procedure inicializarTablero(var tablero: TipoTablero);
var
	f: char;
	c: integer;
begin
	for f:= 'A' to MaxFilas do begin
		for c:= 1 to MaxColumnas do begin

			tablero[f, c]:= '.';															
		end;
	end;
end;

procedure asignarTableros(var juego: TipoJuego);
var
	j: integer;
begin
	for j:= 1 to MaxNJugs do begin
		
		inicializarTablero(juego[j].tablero);
	end;
end;

procedure leerMovimiento(var entrada: text; var m: TipoMovimiento; var ok: boolean);
begin
	leerfila(entrada, m.casilla.fila, ok);
	if ok then
	
		leerColumna(entrada, m.casilla.columna, ok);
end;

function letraEstado(estado: TipoEstado): char;
begin
	if estado = Agua then
		
		result:= 'A'
	else if estado = Tocado then
	
		result:= 'X'
	else
		
		result:= '*'
end;

function estadoLongitud(b: TipoBarco): TipoEstado;
begin
	if (b.longitud = 0) then begin
		
		result:= Hundido;	
	end
	else begin
	
		result:= Tocado;
	end;
end;

function estadoMovimiento(b: TipoBarco; encontrado: boolean): TipoEstado;
begin
	if (encontrado) then begin	// Tocado o hundido

		result:= estadoLongitud(b);	// Si longitud del barco 0, hundido; sino, tocado
	end
	else begin
	
		result:= Agua;	// Agua
	end;
	writeln();
end;

procedure buscarMovimiento(var b: TipoBarco; var m: TipoMovimiento; var encontrado: boolean);
var
	i: integer;
begin
	
	i:= 1;	
	
	while (i <= MaxNLong) and (not encontrado) do begin
		
		//write(' | Casilla ', i, ': ', b.casillas[i].fila, b.casillas[i].columna, ' ');
		if (b.casillas[i].fila = m.casilla.fila) and 
			(b.casillas[i].columna = m.casilla.columna) then begin	// Coincide movimiento con casilla del barco
			
			b.longitud:= b.longitud - 1;	// Resto uno de longitud al barco
			encontrado:= True;
		end
		else 	// Paso a la siguiente casilla del barco
			
			i:= i+ 1;
	end;
	
	m.estado:= estadoMovimiento(b, encontrado);	// Asigno el estado resultante del movimiento
	writeln(m.casilla.fila, m.casilla.columna, ' ', m.estado);
end;

procedure asignarLetra(var tablero: TipoTablero; var b: TipoBarco; var m: TipoMovimiento);
var
	i: integer;
begin
	if (m.estado = Hundido) then begin	// Hundido
	
		for i:= 1 to MaxNLong do begin
		
			tablero[b.casillas[i].fila, b.casillas[i].columna]:= letraEstado(m.estado);	// Cada casilla del barco tendra letra "*"
		end;
	end
	else	// Tocado o agua
	
		tablero[m.casilla.fila, m.casilla.columna]:= letraEstado(m.estado);	// Casilla del movimiento tendra letra "X" o "A"
end;

procedure movimientoJugador(var j: TipoJugador; var m: TipoMovimiento);
var
	i: integer;
	encontrado: boolean;
begin
	i:= 1;
	encontrado:= False;
	
	while (i <= j.flota.nbarcos) and (not encontrado) do begin	// Recorro flota de barcos de jugador
		
		buscarMovimiento(j.flota.barcos[i], m, encontrado);
		asignarLetra(j.tablero, j.flota.barcos[i], m);
		i:= i + 1;
	end;	
end;

procedure escrTablero(tablero: TipoTablero);
var
	f: char;
	c: integer;
begin
	indiceColumnas();
	
	for f:= 'A' to MaxFilas do begin
	
		for c:= 1 to MaxColumnas do begin
		
			write(tablero[f, c], ' ');
		end;
		writeln(f);
	end;
end;

function quienGana(j: integer): integer;
begin
	if (j = 1) then
	
		result:= j + 1
	else
	
		result:= j - 1;
end;

function ganador(juego: TipoJuego): TipoGanador;
var
	j, contador, i: integer;
	encontrado: boolean;
	g: TipoGanador;
begin
	j:= 1;
	encontrado:= False;
	while (j <= MaxNJugs) and (not encontrado) do begin	// Recorro jugadores

		contador:= 0;
		for i:= 1 to juego[j].flota.nbarcos do begin	// Recorro flota de barcos del jugador
		
			if (juego[j].flota.barcos[i].longitud = 0) then	
			
				contador:= contador + 1;
		end;
		if (contador = juego[j].flota.nbarcos) then
			
			encontrado:= True
		else
			
			j:= j + 1
	end;
	
	g.lohay:= encontrado;
	g.quien:= quienGana(j);
	result:= g;
end;

procedure asignarMovimiento(var jugada: TipoJugada; m: TipoMovimiento; n: integer);
begin
	jugada.movs[n]:= m;
	jugada.nmovs:= jugada.nmovs + 1;
end;

procedure jugar(var entrada: Text; var juego: TipoJuego);
var
	n, j: integer;
	ok: boolean;
	m: TipoMovimiento;
begin

	n:= 1; // MOVIMIENTOS
	
	asignarTableros(juego);	// Inicializo los tableros.
	
	repeat
		j:= 1;	// JUGADORES
		
		writeln('Tablero del jugador 2: ');			
		escrTablero(juego[j + 1].tablero); 			// Muestra el tablero del jugador 2 (enemigo)
		
		leerMovimiento(entrada, m, ok);		// Lee el movimiento del jugador 1
		if ok then begin
			
			write('Movimiento del jugador 1: ');
			movimientoJugador(juego[j + 1], m);		// Usa el movimiento con la flota del jugador 2 (enemigo) y reasigna el tablero.
			asignarMovimiento(juego[j].jugada, m, n);	// Asigna el movimiento a la jugada del jugador 1.
		end;	
		
		if (not ganador(juego).lohay) then begin
			writeln('Tablero del jugador 1: ');
			escrTablero(juego[j].tablero);				// Muestra el tablero del jugador 1 (enemigo)
			
			leerMovimiento(entrada, m, ok);	// Lee el movimiento del jugador 2
			if ok then begin

				write('Movimiento del jugador 2: ');	
				movimientoJugador(juego[j], m);			// Usa el movimiento con la flota del jugador 1 (enemigo) y reasigna el tablero.
				asignarMovimiento(juego[j + 1].jugada, m, n);	// Asigna el movimiento a la jugada del jugador 2.	
			end;	
		end;
			
		n:= n + 1;
		
	until (eof(entrada)) or (ganador(juego).lohay)
			or (not ok) or (n > MaxNMovs);
	
	if (n > MaxNMovs) then
		
		fatal('Has superado el limite de movimientos');
	if (not ok) and not (eof(entrada)) then		// MIRAR ESTO SI SE PUEDE SOLUCIONAR

		writeln('Entrada de movimientos erronea');
end;

procedure escrMovimiento(m: TipoMovimiento);
var
	c: TipoCasilla;
begin
	c:= m.casilla;
	write(c.fila);
	write(c.columna, ' ');
	writeln(m.estado);
end;

procedure escrResultado(juego: TipoJuego);
begin
	if ganador(juego).lohay then
		
		writeln('Gana jugador ', ganador(juego).quien)	
		
	else
		writeln('Empate')	
end;

procedure informarFinal(juego: TipoJuego);
var
	n, j: integer;
	esfin: boolean;
begin
	n:= 1; // MOVIMIENTOS
	esfin:= False;
	
	repeat
		j:= 1;	// JUGADORES	
		esfin:= (n = juego[j].jugada.nmovs);
			
		writeln('Movimiento ', n, ':');
		write('Jugador 1: ');
		escrMovimiento(juego[j].jugada.movs[n]);
		write('Jugador 2: ');
		escrMovimiento(juego[j + 1].jugada.movs[n]);
	
		n:= n + 1;
			
	until (esfin);
	escrResultado(juego);
end;

var
	fich: Text;
	juego: TipoJuego;

begin
	assign(fich, 'datos.txt');
	reset(fich);
	
	leerJuego(fich, juego);									
	jugar(fich, juego);
	informarFinal(juego);
	
	close(fich);
end.
