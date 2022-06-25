----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives     
   );
   port (
      clk50_main_i            : in  std_logic;
      clk14_main_i            : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_red_o             : out std_logic_vector(7 downto 0);
      video_green_o           : out std_logic_vector(7 downto 0);
      video_blue_o            : out std_logic_vector(7 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);
      
      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?
      
      -- MEGA65 joysticks
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic
   );
end entity main;

architecture synthesis of main is

-- @TODO: Remove these demo core signals
signal keyboard_n          : std_logic_vector(79 downto 0);

begin

   -- @TODO: Add the actual MiSTer core here
   -- The demo core's purpose is to show a test image and to make sure, that the MiSTer2MEGA65 framework
   -- can be synthesized and run stand-alone without an actual MiSTer core being there, yet
   i_apple2_top : entity work.apple2_top
      port map (
         CLK_14M        => clk14_main_i,
         CLK_50M        => clk50_main_i,

         reset_cold     => '0',
         reset_warm     => '0',
         cpu_type       => '0',
         CPU_WAIT       => '0',
      
         -- main RAM
         ram_we         => open,
         ram_di         => open,
         ram_do         => ( others => '0' ),
         ram_addr       => open,
         ram_aux        => open,
      
         -- video output
         hsync          => video_hs_o,
         vsync          => video_vs_o,
         hblank         => video_hblank_o,
         vblank         => video_vblank_o,
         r              => video_red_o,
         g              => video_green_o,
         b              => video_blue_o,
         SCREEN_MODE    => ( others => '0' ), -- 00: Color, 01: B&W, 10:Green, 11: Amber
         TEXT_COLOR     => '0', -- 1 = color processing for
                                         -- text lines in mixed modes
      
         PS2_Key        => ( others => '0' ),
         joy            => ( others => '0' ),
         joy_an         => ( others => '0' ),
      
         -- mocking board
         mb_enabled 		=> '0',
      
         -- disk control
         TRACK 			=> open,
         DISK_RAM_ADDR  => ( others => '0' ),
         DISK_RAM_DI 	=> ( others => '0' ),
         DISK_RAM_DO    => open,
         DISK_RAM_WE 	=> '0',
         DISK_ACT       => open,
      
         -- HDD control
         HDD_SECTOR     => open,
         HDD_READ       => open,
         HDD_WRITE      => open,
         HDD_MOUNTED    => '0',
         HDD_PROTECT    => '0',
         HDD_RAM_ADDR   => ( others => '0' ),
         HDD_RAM_DI     => ( others => '0' ),
         HDD_RAM_DO     => open,
         HDD_RAM_WE     => '0',
      
         AUDIO_L        => open,
         AUDIO_R        => open,
         TAPE_IN        => '0',
      
         UART_TXD       => open,
         UART_RXD       => '0',
         UART_RTS       => open,
         UART_CTS       => '0',
         UART_DTR       => open,
         UART_DSR       => '0'
      ); -- i_apple2_top

   -- @TODO: Keyboard mapping and keyboard behavior
   -- Each core is treating the keyboard in a different way: Some need low-active "matrices", some
   -- might need small high-active keyboard memories, etc. This is why the MiSTer2MEGA65 framework
   -- lets you define literally everything and only provides a minimal abstraction layer to the keyboard.
   -- You need to adjust keyboard.vhd to your needs
   i_keyboard : entity work.core_keyboard
      port map (
         clk_main_i           => clk14_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         -- @TODO: Create the kind of keyboard output that your core needs
         -- "example_n_o" is a low active register and used by the demo core:
         --    bit 0: Space
         --    bit 1: Return
         --    bit 2: Run/Stop
         example_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

