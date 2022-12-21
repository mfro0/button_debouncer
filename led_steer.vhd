-----------------------------------------------------------------------------------------------------    
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity led_steer is
    generic
    (
        NUM_LEDS        : natural := 8
    );
    port
    (   
        clk             : in std_ulogic;
        left_button,
        right_button    : in std_ulogic;
        led             : out std_ulogic_vector(NUM_LEDS - 1 downto 0) := (others => '0')
    );
end entity led_steer;

architecture rtl of led_steer is
    signal wait_for_release : boolean := false;
    signal led_pos          : natural range 0 to NUM_LEDS - 1 := 0;
begin
    p_steer : process
    begin
        wait until rising_edge(clk);
        if not wait_for_release then
            if left_button then
                if led_pos /= NUM_LEDS - 1 then
                    led_pos <= led_pos + 1;
                end if;
                wait_for_release <= true;
            elsif right_button then
                if led_pos /= 0 then
                    led_pos <= led_pos - 1;
                end if;
                wait_for_release <= true;
            end if;
        elsif not left_button and not right_button then
            wait_for_release <= false;
        end if;
    end process p_steer;
    led <= not std_ulogic_vector(to_unsigned(1, NUM_LEDS) sll led_pos);
end architecture rtl; -- of debouncer_test