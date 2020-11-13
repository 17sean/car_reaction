program CarReaction;
uses crt;
const
	DrivenRecordFileName = 'record.bin';
type
	GameSide = (left, right);

	GameCar = record
		CurX, CurY: integer;
		Symb: char;
		Side: GameSide;
	end;

	GameMap = record
		HomeX, HomeY: integer; 
		CurX, CurY: integer;	
	end;

	GameProp = record
		HomeX, HomeY: integer;
		CurX, CurY: integer;
		Size: integer;
		Symb: char;
		Side: GameSide;
	end;
var
	SpeedTarget, SpeedDelay: integer;
	Driven, DrivenRecord: integer;
	DrivenRecordFile: file of integer;

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

procedure ScreenCheck; { Check screen for accepted size }
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
	if ScreenHeight < 25 then
	begin
		x := (ScreenWidth - 44) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('Please, resize your terminal to 60x25 or more');
		halt(2);
	end;
end;

procedure StartMessage; { Message in begin of game }
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

procedure WantToPlay;  { Ask about start game }
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

procedure zeroing_all(var map: GameMap; var car: GameCar; var prop: GameProp); { Zeroing variables }
begin
	{$I-}
	Driven := 0;
	assign(DrivenRecordFile, DrivenRecordFileName);
	reset(DrivenRecordFile);
	if IOresult <> 0 then
	begin
		DrivenRecord := 0;
		rewrite(DrivenRecordFile);
		write(DrivenRecordFile, DrivenRecord);
		seek(DrivenRecordFile, 0);
	end;
	read(DrivenRecordFile, DrivenRecord);
	close(DrivenRecordFile);	

	SpeedDelay := 100;
	SpeedTarget := 100;

	map.HomeX := (ScreenWidth - 32) div 2;
	map.HomeY := (ScreenHeight - 18) div 2;
	map.CurX := map.HomeX;
	map.CurY := map.HomeY;

	car.Symb := 'I';
	car.CurX := 1;
	car.CurY := 1;

	prop.Symb := '-';
	prop.Size := 14;
	prop.HomeY := map.HomeY;
	prop.CurX := map.HomeX + 1;
	prop.CurY := prop.HomeY; 
	prop.Side := left;
end;

procedure DrawMap(var map: GameMap); { Drawing game map }
var
	i: integer;
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

procedure ShowCar(car: GameCar);
begin
	GotoXY(car.CurX, car.CurY);
	write(car.Symb);

end;

procedure HideCar(car: GameCar);
begin
	GotoXY(car.CurX, car.CurY);
	write(' ');
end;

procedure MoveCar(var car: GameCar; map: GameMap);
begin
	HideCar(car);
	case car.Side of
		left:
			begin
				car.CurX := map.HomeX + 9;
				car.CurY := map.HomeY + 16;
				ShowCar(car);
			end;
		right:
			begin
				car.CurX := map.HomeX + 26;
				car.CurY := map.HomeY + 16;
				ShowCar(car);
			end;
	end;

end;

procedure HandleArrowKey(var car: GameCar; map: GameMap; ch: char);
begin
	case ch of
	#97: car.Side := left;
	#100: car.Side := right;
	end;
	MoveCar(car, map);
end;

procedure ShowProp(prop: GameProp);
var
	i: integer;
begin
	GotoXY(prop.CurX, prop.CurY);
	for i := 1 to prop.Size do
		write(prop.Symb);
end;

procedure HideProp(prop: GameProp);
var
	i: integer;
begin
	GotoXY(prop.CurX, prop.CurY);
	for i := 1 to prop.Size do
		write(' ');
end;

procedure MoveProp(var prop: GameProp; map: GameMap);
begin
	HideProp(prop);
	prop.CurY := prop.CurY + 1;
	Driven := Driven + 1;
	case prop.Side of
		left: prop.CurX := map.HomeX + 1;
		right: prop.CurX := map.HomeX + 20;
	end;	
	ShowProp(prop);
end;

procedure DrivenRecordCheck;
begin
	if Driven > DrivenRecord then
	begin
		rewrite(DrivenRecordFile);
		write(DrivenRecordFile, Driven);
	end;
end;

procedure CollisionChecker(car: GameCar; var prop: GameProp);
var
	x, y: integer;
	i: integer;
begin
	if prop.CurY + 1 = car.CurY then
	begin
		if prop.Side = car.Side then
		begin
			delay(2000);
			clrscr;
			x := (ScreenWidth - 17) div 2;
			y := ScreenHeight div 2;
			GotoXY(x, y);
			write('You driven: ', Driven, 'm');
			y := y + 1;
			GotoXY(x, y);
			DrivenRecordCheck;
			write('Best record: ', DrivenRecord, 'm');
			delay(2000);
			clrscr;
			halt(0);
		end;
	end;
	
	if prop.CurY + 1 = car.CurY then
	begin
		HideProp(prop);
		prop.CurY := prop.HomeY;
		i := random(2);
		case i of
			0: prop.Side := left;
			1: prop.Side := right;
		end;
 	end;
end;

procedure SpeedUp;
var
	i: single;
begin
	i := SpeedDelay;
	if Driven > SpeedTarget then
	begin
		i := i * 0.9;
		SpeedDelay := round(i);
		SpeedTarget := SpeedTarget + 100;
	end;
end;

procedure output_Driven;
var
	x, y: integer;
begin
	if Driven mod 10 = 0 then
	begin
		x := (ScreenWidth - 13) div 2;
		y := 1;
		GotoXY(x, y);
		write('Driven: ', Driven, 'm');
		y := y + 1;
		GotoXY(x, y);
		write('Best record: ', DrivenRecord, 'm');
	end;
end;

var
	car: GameCar;
	map: GameMap;
	prop: GameProp;
	ch: char;
begin
	clrscr;
	randomize;
	{ScreenCheck;}
	zeroing_all(map, car, prop);
	StartMessage;
	WantToPlay;
	DrawMap(map);
	MoveCar(car, map);
	MoveProp(prop, map);
	delay(2000);
	
	while true do
	begin
		if not KeyPressed then
		begin
			delay(SpeedDelay); 
			MoveProp(prop, map);
			SpeedUp;
			output_Driven;
			CollisionChecker(car, prop);
			continue;
		end;
		ch := ReadKey;
		case ch of
			#97: HandleArrowKey(car, map, ch);
			#100: HandleArrowKey(car, map, ch);
			#27: begin clrscr; halt(0); end;
		end;
	end;
end.
