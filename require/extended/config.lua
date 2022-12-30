extendedConfig = {
	Locale = "fr",

	Accounts = {
		bank = "Banque",
		black_money = "Argent sale",
		money = "Espèces"
	},

	StartingAccountMoney 	= {bank = 50000},
	EnableSocietyPayouts 	= false, -- pay from the society account that the player is employed at? Requirement: esx_society

	EnableHud            	= false, -- enable the default hud? Display current job and accounts (black, bank & cash)
	MaxWeight            	= 50,   -- the max inventory weight without backpack
	PaycheckInterval         = 10 * 60000, -- how often to recieve pay checks in milliseconds
	EnableDebug              = false, -- Use Debug options?
	EnableDefaultInventory   = false, -- Display the default Inventory ( F2 )
	EnableWantedLevel    	= false, -- Use Normal GTA wanted Level?
	EnablePVP                = true, -- Allow Player to player combat
	
	Multichar                = false, -- Enable support for esx_multicharacter
	Identity                 = true -- Select a characters identity data before they have loaded in (this happens by default with multichar)

}