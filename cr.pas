program CarReaction;
uses crt;
const
	DrivenRecordFileName = 'record.bin';
type
	GameSide = (left, right);

	car = record
		x, y: integer;
		symb: char;
		side: GameSide;
	end;

	map = record
		x, y: integer;	
	end;

	prop = record
		HomeX, HomeY: integer;
		CurX, CurY: integer;
		size: integer;
		symb: char;
		side: GameSide;
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
		write('Error, i can`t parse your input');
		delay(1000);
		clrscr;
	end;
end;

procedure StartMessage;
var
	x, y, i: integer;
    s: string;
begin
	s := 'Car Reaction.';
	x := (ScreenWidth - length('Car Reaction.')) div 2;
	y := ScreenHeight div 2;
	GotoXY(x, y);
	for i := 1 to length('Car Reaction.') do
	begin
		write(s[i]);
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
	until ch in ['y', 'Y', 'n', 'N'];
	clrscr;
	if ch in ['n', 'N'] then
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

procedure Init(var m: map; var c: car; var p: prop);
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

	m.x := (ScreenWidth - 32) div 2;
	m.y := (ScreenHeight - 18) div 2;

	c.symb := 'I';
	c.x := 1;
	c.y := 1;

	p.symb := '-';
	p.size := 14;
	p.HomeY := m.y;
	p.CurX := m.x + 1;
	p.CurY := p.HomeY; 
	p.side := left;
end;

procedure DrawMap(m: map);
var
	i: integer;
begin
	for i := 1 to 20 do	
	begin
		GotoXY(m.x, m.y);
		write(#124, '                ');
		if (i mod 4) = 0 then
			write(#124)
		else
			write(' ');
		write('                ', #124);
		m.y += 1;
		GotoXY(m.x, m.y);
	end;
end;

procedure ShowCar(c: car);
begin
	GotoXY(c.x, c.y);
	write(c.symb);
end;

procedure HideCar(c: car);
begin
	GotoXY(c.x, c.y);
	write(' ');
end;

procedure MoveCar(var c: car; m: map);
begin
	HideCar(c);
	case c.side of
		left:
			begin
				c.x := m.x + 9;
				c.y := m.y + 16;
				ShowCar(c);
			end;
		right:
			begin
				c.x := m.x + 26;
				c.y := m.y + 16;
				ShowCar(c);
			end;
	end;

end;

procedure HandleArrowKey(var c: car; m: map);
var
    ch: char;
begin
    ch := ReadKey;
    case ch of
        'a', 'A': c.side := left;
        'd', 'D': c.side := right;
        #27:
        begin
            clrscr;
            halt(0);
        end;
    end;
	MoveCar(c, m);
end;

procedure ShowProp(p: prop);
var
	i: integer;
begin
	GotoXY(p.CurX, p.CurY);
	for i := 1 to p.size do
		write(p.symb);
end;

procedure HideProp(p: prop);
var
	i: integer;
begin
	GotoXY(p.CurX, p.CurY);
	for i := 1 to p.Size do
		write(' ');
end;

procedure MoveProp(var p: prop; m: map);
begin
	HideProp(p);
	p.CurY := p.CurY + 1;
	Driven := Driven + 1;
	case p.side of
		left: p.CurX := m.x + 1;
		right: p.CurX := m.x + 20;
	end;	
	ShowProp(p);
end;

procedure DrivenRecordCheck;
begin
	if Driven > DrivenRecord then
	begin
		rewrite(DrivenRecordFile);
		write(DrivenRecordFile, Driven);
        close(DrivenRecordFile);
	end;
end;

procedure CollisionChecker(c: car; var p: prop);
var
	x, y: integer;
	i: integer;
begin
	if p.CurY + 1 = c.y then
	begin
		if p.side = c.side then
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
	
	if p.CurY + 1 = c.y then
	begin
		HideProp(p);
		p.CurY := p.HomeY;
		i := random(2);
		case i of
			0: p.Side := left;
			1: p.Side := right;
		end;
 	end;
end;

procedure SpeedUp;
begin
	if Driven > SpeedTarget then
	begin
		SpeedDelay := round(SpeedDelay * 0.9);
		SpeedTarget := SpeedTarget + 100;
	end;
end;

procedure OutputDriven;
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
	c: car;
	m: map;
	p: prop;
begin
	clrscr;
	randomize;
	Init(m, c, p);
	StartMessage;
	WantToPlay;
	DrawMap(m);
	MoveCar(c, m);
	MoveProp(p, m);
	delay(2000);
	while true do
	begin
		if not KeyPressed then
		begin
			delay(SpeedDelay); 
			MoveProp(p, m);
			SpeedUp;
			OutputDriven;
			CollisionChecker(c, p);
			continue;
		end;
        HandleArrowKey(c, m);
	end;
end.
