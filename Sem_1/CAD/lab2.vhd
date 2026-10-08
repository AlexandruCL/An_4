ENTITY clk_gen IS
	GENERIC(t_high: TIME:=30 ns; t_period: TIME:=50 ns; t_reset: TIME:=10 ns);
	PORT(clock: OUT BIT:='1'; reset : OUT BIT);
END clk_gen;

ARCHITECTURE behave OF clk_gen IS
BEGIN
	reset<='0', '1' AFTER t_reset;
	
	PROCESS
	BEGIN
	--next 3 lines suspend the process if the simulation time is > 10 micro seconds.
		--if Now > 10 us then
		--	wait;
		--end if;

		clock<='1', '0' AFTER t_high;
		WAIT FOR t_period;
	END PROCESS;
END ARCHITECTURE;

ENTITY counter1 IS
	GENERIC( delay: TIME := 10 ns;
		MAX_VAL: INTEGER :=4);
	PORT(clock, reset, load: IN BIT;
		up: IN BIT;             -- '1' = count up, '0' = count down
		parallel_in: IN INTEGER;
		output: OUT INTEGER;
		ovr: OUT BIT);
END counter1;

ARCHITECTURE behave OF counter1 IS
--declaratii de semnale, componente, etc
-- signal declarations, component declarations, etc
BEGIN

PROCESS( clock, reset)
	VARIABLE temp: INTEGER;
	VARIABLE ovr_v: BIT := '0';
BEGIN

	IF reset='0' THEN
		temp := 0;
		ovr_v := '0';
	ELSIF clock='1' AND clock'EVENT and clock'LAST_VALUE='0' THEN
		ovr_v := '0';
		IF load='1' THEN
			temp := parallel_in MOD MAX_VAL;
		ELSE
			IF up='1' THEN
				-- counting up: overflow on MAX_VAL-1 -> 0
				IF temp = MAX_VAL - 1 THEN
					ovr_v := '1';
				END IF;
				temp := (temp+1) MOD MAX_VAL;
			ELSE
				-- counting down: overflow on 0 -> MAX_VAL-1
				IF temp = 0 THEN
					ovr_v := '1';
				END IF;
				temp := (temp - 1 + MAX_VAL) MOD MAX_VAL;
			END IF;
		END IF;
	END IF;

	output <= temp AFTER delay;
	ovr <= ovr_v AFTER delay;
END PROCESS;

END ARCHITECTURE behave;

ENTITY test IS

END test;

ARCHITECTURE struct OF test IS

	COMPONENT counter1 IS
		GENERIC( delay: TIME := 10 ns;
			MAX_VAL: INTEGER := 4);
		PORT(clock, reset, load: IN BIT;
			up: IN BIT;
			parallel_in: IN INTEGER;
			output: OUT INTEGER;
			ovr: OUT BIT);
	END COMPONENT;

	COMPONENT  clk_gen IS
		GENERIC(t_high: TIME:=30 ns; t_period: TIME:=50 ns; t_reset: TIME:=10 ns);
		PORT(clock: OUT BIT:='1'; reset : OUT BIT);
	END COMPONENT;

	SIGNAL clock_s, reset_s, load_s : BIT;
	SIGNAL up_s : BIT := '1';
	SIGNAL parallel_in_s: INTEGER := -5;

	SIGNAL output_s : INTEGER;      -- first counter output
	SIGNAL ovr_s    : BIT;          -- first counter overflow -> drives second counter clock

	SIGNAL output2_s : INTEGER;     -- second counter output
	SIGNAL ovr2_s    : BIT;         -- second counter overflow
BEGIN

-- First counter: driven by the generated clock
et1: counter1 GENERIC MAP(delay => 5 ns, MAX_VAL => 4)
	PORT MAP ( clock => clock_s, reset => reset_s, load => load_s,
		up => up_s, parallel_in => parallel_in_s,
		output => output_s, ovr => ovr_s);

-- Second counter: clocked by the overflow (ovr) of the first counter.
-- It never loads, so load is tied to '0' and parallel_in is unused (0).
et2: counter1 GENERIC MAP(delay => 5 ns, MAX_VAL => 4)
	PORT MAP ( clock => ovr_s, reset => reset_s, load => '0',
		up => up_s, parallel_in => 0,
		output => output2_s, ovr => ovr2_s);

et3: clk_gen GENERIC MAP (t_high => 40ns, t_period => 100ns, t_reset => 30ns)
	PORT MAP (clock => clock_s, reset => reset_s );

load_s <='0', '1' after 240 ns, '0' AFTER 440 ns;

-- Exercise both directions: count up, then switch to down
up_s <= '1', '0' AFTER 1200 ns;

parallel_in_s <= 100 AFTER 150 ns;

END struct; 
