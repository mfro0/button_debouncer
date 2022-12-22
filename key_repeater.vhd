library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_repeater is
    generic
    (
        -- limit comparision width to this much (upper) bits of the counters to reduce resource consumption
        COMPARE_WIDTH       : natural := 16;
        --
        -- bit lengths for counters are solely dependent on the bit lentgh of these generics, i.e.
        -- when you define these as 64 bit constants, all counters and comparisions
        -- will use the width defined here.
        --
        -- The values defined here are suitable for a 50 MHz clock. Adapt accordingly.
        --
        INITIAL_DELAY       : unsigned(31 downto 0) := 32d"5_000_000"; -- initial delay until key repeat starts
        REPEAT_DELAY        : unsigned(31 downto 0) := 32d"4_000_000"  -- inter-key delay when repeat is active
    );
    port
    (
        clk                 : in std_ulogic;
        key                 : in std_ulogic;
        key_out             : buffer std_ulogic
    );
end entity key_repeater;

architecture rtl of key_repeater is
    signal initial_counter  : unsigned(INITIAL_DELAY'range);
    signal repeat_counter   : unsigned(REPEAT_DELAY'range);
    signal repeating        : boolean;
    constant I_DELAY        : unsigned(COMPARE_WIDTH - 1 downto 0) := INITIAL_DELAY(INITIAL_DELAY'high downto INITIAL_DELAY'high - COMPARE_WIDTH + 1);
    constant R_DELAY        : unsigned(COMPARE_WIDTH - 1 downto 0) := REPEAT_DELAY(REPEAT_DELAY'high downto REPEAT_DELAY'high - COMPARE_WIDTH + 1);
    
    --
    -- define aliases for the upper COMPARE_WIDTH bits of the delays to reduce resource usage
    --
    --
    alias i_counter_cmp : unsigned(COMPARE_WIDTH - 1 downto 0) is initial_counter(initial_counter'high downto initial_counter'high - COMPARE_WIDTH + 1);
    alias r_counter_cmp : unsigned(COMPARE_WIDTH - 1 downto 0) is repeat_counter(repeat_counter'high downto repeat_counter'high - COMPARE_WIDTH + 1);
    
begin
    p_repeater : process(all)
    begin
        if rising_edge(clk) then
            if key then                     -- if key is pressed, start counting
                if not repeating then
                    initial_counter <= initial_counter + 1;
                    if i_counter_cmp = I_DELAY then
                        repeating <= true;
                    end if;
                end if;
            else
                initial_counter <= (others => '0');
                repeating <= false;
                key_out <= '0';
            end if;
            
            if repeating then
                repeat_counter <= repeat_counter + 1;
                if r_counter_cmp = R_DELAY then
                    key_out <= not key_out;     -- artificially press/release key
                    repeat_counter <= (others => '0');
                end if;
            else
                repeat_counter <= (others => '0');
                key_out <= key;
            end if;
        end if;
    end process p_repeater;
end architecture rtl;
        