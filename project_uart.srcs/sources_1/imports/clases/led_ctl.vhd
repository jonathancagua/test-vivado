library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity led_ctl is
	port(
		clk_rx:			in std_logic;					-- Clock input
		rst_clk_rx:		in std_logic;					-- Active HIGH reset - synchronous to clk_rx
		btn_clk_rx:		in std_logic;					-- Button to swap low and high pins
		rx_data:		in std_logic_vector(7 downto 0);-- 8 bit data output
		rx_data_rdy:	in std_logic;					-- valid when rx_data_rdy is asserted
		led_o:			out std_logic_vector(3 downto 0)-- The LED outputs
	);
end;


architecture led_ctl_arq of led_ctl is
	signal old_rx_data_rdy: std_logic;
	--signal char_data: std_logic_vector(7 downto 0);
	signal cnt_data: std_logic_vector(7 downto 0);
	signal led_pipeline_reg: std_logic_vector(3 downto 0);
	--SIGNAL cnt : UNSIGNED(7 DOWNTO 0) := "00000000";
begin

	process(clk_rx)
		variable cnt : UNSIGNED(7 downto 0);
		variable char_data: std_logic_vector(7 downto 0);
	begin
		if rising_edge(clk_rx) then
			if rst_clk_rx = '1' then
				old_rx_data_rdy <= '0';
				char_data       := "00000000";
				led_o           <= "0000";
				--cnt_data		<= "00000000";
				cnt 			:= (others => '0');
				cnt_data 		<= std_logic_vector(cnt);
			else
				-- Capture the value of rx_data_rdy for edge detection
				old_rx_data_rdy <= rx_data_rdy;
				-- If rising edge of rx_data_rdy, capture rx_data
				if (rx_data_rdy = '1' and old_rx_data_rdy = '0') then
					char_data := rx_data;	
					if char_data = "01000001" then 
						cnt := cnt + 1;
					end if;
					if char_data = "01000010" then 
						cnt := cnt - 1;
					end if;
				end if;
				cnt_data 		<= std_logic_vector(cnt);
				--Output the normal data or the data with high and low swapped
				if btn_clk_rx = '1' then
					led_pipeline_reg <= cnt_data(7 downto 4);
				else
					led_pipeline_reg <= cnt_data(3 downto 0);
				end if;
			end if;	-- if !rst
		end if;
		led_o <= led_pipeline_reg;
	end process;
end;