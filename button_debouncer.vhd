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
    subtype counter_type is natural range 0 to REQ_TICKS_STABLE - 1;
    signal counter      : counter_type;
    signal btn_history  : std_ulogic_vector(SYNCHRONIZER_WIDTH downto 0) := (others => '0');
begin
    p_debounce : process(all)
    begin
        if rising_edge(clk) then
            btn_history <= btn_history(btn_history'left - 1 downto btn_history'right) & button_in;
            if btn_history(btn_history'left) /= btn_history(btn_history'left - 1) then
                -- button changed, reset counter to beginning
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
            
            if counter = counter_type'right - 1 then            -- finished counting
                button_out <= btn_history(btn_history'left);    -- output leftmost value
            end if;
        end if;
    end process p_debounce;
end architecture rtl;
