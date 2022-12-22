-----------------------------------------------------------------------------------------------------    
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity debouncer_test is 
    port
    (       
        MAX10_CLK1_50   : in std_ulogic;
        KEY             : in std_ulogic_vector(1 downto 0);
        LED             : out std_ulogic_vector(7 downto 0) := (others => '1')    -- all off
    );
end entity debouncer_test;

architecture rtl of debouncer_test is
    signal btn                      : std_ulogic_vector(1 downto 0);
    
    alias left_button               : std_ulogic is btn(1);
    alias right_button              : std_ulogic is btn(0);
    
    signal left_button_repeated,
           right_button_repeated    : std_ulogic;
begin
    i_debouncer1 : entity work.button_debouncer
        port map
        (
            clk         => MAX10_CLK1_50,
            button_in   => not KEY(0),
            button_out  => right_button
        );

    i_debouncer2 : entity work.button_debouncer
        port map
        (
            clk         => MAX10_CLK1_50,
            button_in   => not KEY(1),
            button_out  => left_button
        );

    i_repeater1 : entity work.key_repeater
        port map
        (
            clk         => MAX10_CLK1_50,
            key         => left_button,
            key_out     => left_button_repeated
        );

    i_repeater2 : entity work.key_repeater
        port map
        (
            clk         => MAX10_CLK1_50,
            key         => right_button,
            key_out     => right_button_repeated
        );
            
    i_steering : entity work.led_steer
        generic map
        (
            NUM_LEDS        => LED'length
        )
        port map
        (
            clk             => MAX10_CLK1_50,
            left_button     => left_button_repeated,
            right_button    => right_button_repeated,
            led             => LED
        );
end architecture rtl; -- of debouncer_test 
        