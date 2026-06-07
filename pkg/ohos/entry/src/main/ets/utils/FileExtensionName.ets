export const SUPPORTED_EXTENSIONS = [
  '.7z', '.zip', '.gz',                       // 压缩格式
  '.bin', '.img', '.iso', '.chd', '.cue', '.ccd', '.cdi', '.gdi', '.nrg', '.mds', '.toc', '.mdf', // 通用镜像/光盘
  '.cso', '.ciso', '.zso', '.ecm', '.pbp', '.m3u', '.m3u8',  // 压缩/光盘镜像
  '.dsk', '.sna', '.kcr', '.tap', '.cdt', '.voc', '.cpr',    // CPC
  '.do', '.nib', '.po', '.woz', '.2mg', '.2img', '.iie', '.apl', '.hdv', '.yaml', // AppleWin
  '.dmy', '.k1', '.a1', '.6c', '.c6', '.d2', '.s1', '.f4', '.a4', '.1da', '.da1', '.c4', '.4c', '.4d', '.d7', '.d4', // DOCE
  '.cmd',                      // MAME
  '.hex', '.arduboy',         // Arduboy
  '.a26', '.xfd', '.atr', '.dcm', '.cas', '.a52', '.atx', '.car', '.rom', '.com', '.xex', '.a78', '.cdf', // Atari
  '.j64', '.jag', '.abs', '.cof', '.prg', // Jaguar
  '.inx', '.lyx', '.bll', '.o', // Lynx
  '.st', '.msa', '.stx', '.dim', '.ipf', '.vhd', '.gem', '.ide', // Atari ST
  '.b',                        // Tamagotchi P1
  '.ws', '.wsc', '.pc2', '.pcv2', // WonderSwan
  '.game', '.88',              // Cannonball
  '.exe', '.dll', '.so',       // Cave Story
  '.hai', '.chai', '.chailove', // ChaiLove
  '.ch8', '.sc8', '.xo8',     // CHIP-8
  '.col', '.cv', '.myv',      // ColecoVision
  '.adf', '.adz', '.dms', '.fdi', '.hdf', '.hdz', '.iha', '.slave', '.info', '.uae', '.rp9', // Amiga
  '.d64', '.d71', '.d80', '.d81', '.d82', '.g64', '.g41', '.x64', '.t64', '.p00', '.crt', // Commodore
  '.d6z', '.d7z', '.d8z', '.g6z', '.g4z', '.x6z', '.vfl', '.vsf', '.nbz', '.d2m', '.d4m', // Commodore 压缩
  '.20', '.40', '.60', '.a0', '.b0', // Commodore 其他
  '.wad', '.iwad', '.pwad',   // Doom
  '.pk4',                      // Doom3
  '.bat', '.conf', '.dosz', '.ima', '.jrc', '.tc', // DOS
  '.dtf', '.trn', '.128', '.bas', '.tzx', '.wav', '.tvcwav', // EP128EMU
  '.chf',                      // ChannelF
  '.map', '.aba', '.seq', '.lev', // REminiscence
  '.gam',                      // GAM4980
  '.ay', '.gbs', '.gym', '.hes', '.kss', '.nsf', '.nsfe', '.sap', '.spc', '.vgm', '.vgz', // Game Music Emu
  '.ver',                      // Vectrex
  '.mgw',                      // Handheld Electronic
  '.z1', '.z3',                // Infocom Z-Machine
  '.jar', '.sqc', '.jam', '.jad', '.kjx', '.sec', '.sto', // Java ME
  '.sp', '.sp0', '.sp1', '.sp2', '.sp3', '.sp4', '.sp5', '.sp6', '.sp7', '.sp8', '.sp9', // Java ME (Siemens)
  '.ogv', '.dirksimple',      // Laserdisc
  '.nx',                       // LowRes NX
  '.lutro', '.love', '.lua',  // Lua Engine
  '.hvf',                      // MAC
  '.int',                      // Intellivision
  '.duck',                     // MD/CB
  '.md', '.smd', '.gen',      // Sega
  '.gg', '.sms',               // Sega掌机
  '.mx1', '.mx2',             // MSX
  '.uw8', '.wasm',            // MicroW8 / WASM-4
  '.desktop',                  // Mr.Boom
  '.ri', '.sg', '.sc', '.sf', // MSX/SVI/ColecoVision/SG-1000
  '.pce', '.sgx',             // PCE/PCE-CD
  '.d88', '.u88',             // PC-8000/PC-8800
  '.d98', '.98d', '.fdd', '.2hd', '.tfd', '.88d', '.hdm', '.xdf', '.dup', '.hdi', '.thd', '.nhd', '.hdd', '.hdn', // PC98
  '.dx1', '.2d',              // X1
  '.3ds', '.3dsx', '.axf', '.cci', '.cxi', '.app', // 3DS
  '.nds', '.ids', '.dsi',     // NDS
  '.gb', '.gbc', '.cgb', '.dmg', '.sgb', // GB/GBC
  '.gba',                      // GBA
  '.fds', '.nes', '.unif', '.unf', // FC
  '.n64', '.z64', '.v64', '.ndd', '.u1', // N64
  '.min',                      // Pokemon Mini
  '.fig', '.sfc', '.smc', '.gd3', '.gd7', '.dx2', '.bsx', '.swc', '.bs', // SFC
  '.vb', '.vboy',             // VB
  '.prc', '.pqa', '.pdb',    // Palm OS
  '.p8', '.png',              // PICO-8
  '.cdg',                      // PocketCDG
  '.pak',                      // Quake
  '.pk3',                      // Quake3
  '.cart', '.bms', '.mdx', '.vec', // ROM Cleaner
  '.idb', '.izh', '.easyrpg', // RPG Maker 2000/2003
  '.ist',                      // SD/NAOMI
  '.68k', '.sgd',             // MD
  '.32x', '.pco',             // 32X
  '.p', '.t81',               // ZX81
  '.z80', '.rzx', '.scl', '.trd', '.dck', '.szx', // ZX Spectrum
  '.neo',                      // NeoGeo AES/MVS
  '.ngp', '.ngc', '.ngpc', '.npc', // Neo Geo Pocket
  '.psexe', '.cbn', '.psf',  // PS1
  '.dump',                     // PS2
  '.prx',                      // PSP
  '.8xp', '.8xk', '.8xg',    // TI-83
  '.cps',                      // The Powder Toy
  '.tic',                      // TIC-80
  '.phd', '.psx', '.tr2',    // Tomb Raider
  '.uze',                      // Uzebox
  '.vaporbin',                 // VaporSpec
  '.vms', '.dci',             // VeMUlator
  '.v32',                      // Vircon32
  '.sv',                       // Supervision
  '.wl6', '.n3d', '.sod', '.sdm', '.wl1', // Wolfenstein 3D
  '.mgt', '.sbt', '.sad', //SAM Coupe
  '.elf', '.gdi', '.lst', '.dat', '.skr', '.tsp', // 其他
  // ScummVM 游戏ID（含数字/字母标识符，已去除含空格/特殊字符的非扩展名项如 "Seuss's ABC"、"#02"、"$00"、"(A)"、"2 US"、"99 (PG)"）
  '.0', '.1', '.2', '.3', '.4', '.5', '.6', '.8', '.12', '.25', '.26', '.34',
  '.84', '.85', '.86', '.87', '.99', '.101', '.102', '.455', '.512',
  '.000', '.001', '.002', '.003', '.004', '.005', '.006', '.007', '.009', '.025',
  '.1c', '.acx', '.ad', '.adv', '.aga', '.ald', '.all', '.an', '.ang',
]
