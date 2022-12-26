library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--
-- debounce a button
--

entity button_debouncer is
    generic
    (
        REQ_TICKS_STABLE    : natural := 30000; -- Number of clock ticks the signal must be constant to consider it stable.
                                                -- The number provided here is suitable for a 50 MHz clock.
        SYNCHRONIZER_WIDTH  : natural := 2      -- Number of synchronizer bits
    );
    port
    (
        clk                 : in std_ulogic;
        
        button_in           : in std_ulogic;
        button_out          : out std_ulogic
    );
end entity button_debouncer;

architecture rtl of button_debouncer is
    function next_power_of2(number : natural) return natural is
        variable n : natural := number;
        variable x : natural := 1;
	begin
        while n > 0 loop
            n := n / 2;
            x := x * 2;
        end loop;
        return x;
    end function next_power_of2;
	
    constant t : natural := next_power_of2(REQ_TICKS_STABLE);
    subtype counter_type is natural range 0 to t - 1;
    signal counter      : counter_type;
    signal btn_history  : std_ulogic_vector(SYNCHRONIZER_WIDTH downto 0) := (others => '0');
begin
    p_debounce : process(all)
    begin
        assert false report "REQ_TICKS_STABLE=" & natural'image(REQ_TICKS_STABLE) & " t=" & natural'image(t) severity note;
        if rising_edge(clk) then
            btn_history <= btn_history(btn_history'left - 1 downto btn_history'right) & button_in;
            if btn_history(btn_history'left) /= btn_history(btn_history'left - 1) then
                -- button changed, reset counter to beginning
                counter <= 0;
            else
                counter <= to_integer(to_unsigned(counter + 1, 32) and to_unsigned(counter_type'right, 32));
            end if;
            
            if counter = counter_type'right - 1 then            -- finished counting
                button_out <= btn_history(btn_history'left);    -- output leftmost value
            end if;
        end if;
    end process p_debounce;
end architecture rtl;
