----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/02/2026 05:03:17 PM
-- Design Name: 
-- Module Name: Accelerator_Wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Accelerator_Wrapper is
    Generic(input_datalength : integer := 8;
            output_datalength : integer := 32;
            array_dim : integer := 16;
            address_size : integer := 13;
            data_width : integer := 32);
    Port(
        s_axis_h2a_aclk, s_axis_h2a_aresetn : in std_logic;
        s_axis_h2a_tdata : in std_logic_vector(31 downto 0);
        s_axis_h2a_tvalid, s_axis_h2a_tlast, m_axis_a2h_tready : in std_logic;
        m_axis_a2h_tdata : out std_logic_vector(output_datalength-1 downto 0);
        m_axis_a2h_tvalid, m_axis_a2h_tlast, s_axis_h2a_tready : out std_logic;
        m_axis_a2h_tkeep : out std_logic_vector(3 downto 0)
    );
end Accelerator_Wrapper;

architecture Behavioral of Accelerator_Wrapper is

begin

    Acc_Inst: Accelerator
    Generic map(input_datalength => input_datalength,
                output_datalength => output_datalength,
                array_dim => array_dim,
                address_size => address_size,
                data_width => data_width)
    Port map(CLK => s_axis_h2a_aclk,
             Reset => s_axis_h2a_aresetn,
             Element_In => s_axis_h2a_tdata,
             Element_Valid_In => s_axis_h2a_tvalid,
             Element_In_last => s_axis_h2a_tlast,
             host_ready => m_axis_a2h_tready,
             Element_Out => m_axis_a2h_tdata,
             Element_Valid_Out => m_axis_a2h_tvalid,
             Element_Out_last => m_axis_a2h_tlast,
             acc_ready => s_axis_h2a_tready);
    
    m_axis_a2h_tkeep <= (others => '1');
    
end Behavioral;
