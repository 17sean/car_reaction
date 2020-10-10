program CarReaction;
uses crt;
type
	GameCar = record
		CurX, CurY: integer;
		Symb: char;
	end;
	GameMap = record
		HomeX, HomeY: integer; 
		CurX, CurY: integer;	
	end;	
	GameProp = record
		HomeX, HomeY: integer;
		CurX, CurY: integer;
		Size: integer; { циклом отрисовывается }
		Symb: char;
	end;

procedure IOresult_check;
var
	x, y: integer;
begin
	if IOresult <> 0 then
	begin
		x := (ScreenWidth - 30) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		TextColor(Red);
		write('Error, i can`t parse your input');
		delay(1000);
		clrscr;
	end;
end;

{ procedure zeroing_all; } { TODO } 

procedure ScreenCheck;
var
	x, y: integer;
begin
	if ScreenWidth < 60 then
	begin
		x := (ScreenWidth - 44) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('Please, resize your terminal to 60x25 or more');
		halt(2);
	end;
	if ScreenHeight < 25 then { Screen Check } 
	begin
		x := (ScreenWidth - 44) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('Please, resize your terminal to 60x25 or more');
		halt(2);
	end;
end;

procedure StartMessage;
var
	i, x, y: integer;
	locmsg: string;
	len: integer;
begin
	locmsg := 'Car Reaction.';
	len := length(locmsg);
	x := (ScreenWidth - len) div 2;
	y := ScreenHeight div 2;
	GotoXY(x, y);
	for i := 1 to len do
	begin
		write(locmsg[i]);
		delay(75);
	end;
	delay(1000);
end;

procedure WantToPlay;
var
	x, y: integer;
	ch: char;
begin
	x := (ScreenWidth - 18) div 2;
	y := ScreenHeight div 2;

	repeat
		clrscr;
		GotoXY(x, y);
		write('Want to play? [Y/n]');
		ch := ReadKey;
	until ch in [#78, #110, #89, #121];
	clrscr;
	if ch in [#78, #110] then
	begin
		x := (ScreenWidth - 15) div 2;
		y := ScreenHeight div 2;

		GotoXY(x, y);
		write('See you later...');
		delay(1000);
		clrscr;
		halt(0);
	end;
end;

procedure zeroing_all; {TODO}
begin
end;
{--------------------------------------------------------}
procedure DrawMap(var map: GameMap);
var
	i: integer; {16 расстояние между рядами, 5 между полосками}
begin
	GotoXY(map.HomeX, map.HomeY);
	for i := 1 to 20 do	
	begin
		GotoXY(map.HomeX, map.CurY);
		write(#124, '                ');
		if (i mod 4) = 0 then
			write(#124)
		else
			write(' ');
		write('                ', #124);
		map.CurY := map.CurY + 1;
		GotoXY(map.HomeX, map.CurY);
	end;
end;


var
	car: GameCar;
	map: GameMap;
	prop: GameProp;
begin
	clrscr;
	ScreenCheck;
	{-----------------}
	zeroing_all; { включает в себя нижние присваивания } {todo}
	
	car.Symb := 'I'; { Car settins }
	
	{car.CurX := ; todo
	car.CurY := ; todo}

	prop.Symb := '-'; { Prop settings }
	prop.Size := 14;

	{prop.HomeX := ; todo
	prop.HomeY := ;  todo}

	prop.CurX := prop.HomeX;
	prop.CurY := prop.HomeY;

	map.HomeX := (ScreenWidth - 32) div 2;
	map.HomeY := 2;

	map.CurX := map.HomeX;
	map.CurY := map.HomeY;
	{----------------------}
	StartMessage;
	WantToPlay;
	DrawMap(map);
	while true do
	begin
		break;
	end;
end.
