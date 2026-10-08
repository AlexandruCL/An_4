
-- the file gates.vhd

ENTITY xor2 IS
	GENERIC(del: TIME:=3 ns);
	PORT(x1,x2: IN BIT;
		y: OUT BIT);
END xor2;

ARCHITECTURE behave OF xor2 IS
-- signal declarations, etc, 
-- variables MAY NOT be declared in architectures

BEGIN
y <= x1 XOR x2 AFTER del;
END behave;

ENTITY inverter IS 
	GENERIC(del: TIME:=4 ns);
	PORT(x: IN BIT;
		y: OUT BIT);
END inverter;

ARCHITECTURE behave OF inverter IS
-- declarations
BEGIN
y <= NOT x AFTER del;
END behave;