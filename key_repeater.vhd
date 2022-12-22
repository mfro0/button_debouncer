library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_repeater is
    generic
    (
        INITIAL_DELAY       : unsigned := d"5_000_000"; -- initial delay until key repeat starts
        REPEAT_DELAY        : unsigned := d"4_000_000"  -- inter-key delay when repeat is active
    );
    port
    (
        clk                 : in std_ulogic;
        key                 : in std_ulogic;
        key_out             : out std_ulogic
    );
end entity key_repeater;

architecture rtl of key_repeater is
    signal initial_counter  : unsigned(63 downto 0);
    signal repeat_counter   : unsigned(63 downto 0);
    signal repeating        : boolean;
begin
    p_repeater : process(all)
    begin
        if rising_edge(clk) then
            if key then                     -- if key is pressed, start counting
                if not repeating then
                    initial_counter <= initial_counter + 1;
                    if initial_counter = INITIAL_DELAY - 1 then
                        repeating <= true;
                    end if;
                end if;
            else
                initial_counter <= 64d"0";
                repeating <= false;
                key_out <= '0';
            end if;
            
            if repeating then
                repeat_counter <= repeat_counter + 1;
                if repeat_counter = REPEAT_DELAY - 1 then
                    key_out <= not key_out;     -- artificially press/release key
                    repeat_counter <= 64d"0";
                end if;
            else
                repeat_counter <= 64d"0";
                key_out <= key;
            end if;
        end if;
    end process p_repeater;
end architecture rtl;
        