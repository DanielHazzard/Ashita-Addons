-- ADD THE NAME OF MONSTERS TO WHICH YOU CAN STEAL MP FROM BELOW, SIMPLY ADD THE NAME BETWEEN QUOTATION MARKS AND DON'T FORGET THE COMMENT AFTER EACH
KnownMP_monsters = {"Apex Crab"}-- Example: {'Apex Crab', 'Steelshell', 'Metalcruncher Worm'}

AttemptMyrkr = true -- SET TO TRUE TO USE MRKYR OR FALSE TO NOT ( NOT YET IMPLEMENTED )

-- ASPIR WILL BE USED WHEN CURRENT MP IS BELOW THE DEFINED AMOUNT
Aspir_MPAmount = 300

-- ATTEMPT ASPIR WHEN POSSIBLE AND WHEN NOT BUSY (IE. NOT BURSTING)
Aspir_NoBurst = true

-- SILENCE AILMENT VARIABLES
AttemptSilenceRemoval = false

-- ITEMS TO REMOVE SILENCE, SET TO TRUE TO ENABLE. ORDER: Echo Drops, Catholicon, Vicar's Drink, Remedy Ointment, Remedy
UseEchoDrops = true
UseCatholicon = true
UseVicarsDrink = true
UseRemedyOintment = true
UseRemedy = true

-- BURST MAGIC, EDIT THE ELEMENT OF SPELLS TO USE UNDER THE SKILLCHAINS, ONLY ENTER THE ELEMENT NOT ANY TIER NUMBER, TO DISABLE THAT SKILLCHAIN ENTER void
BurstMagic = {
        -- LEVEL 3 and 4
        ["Radiance"] = "Thunder",
        ["Light"] = "Thunder",
        ["Umbra"] = "Blizzard",
        ["Darkness"] = "Blizzard",
        -- LEVEL 2
        ["Gravitation"] = "Stone",
        ["Fragmentation"] = "Thunder",
        ["Distortion"] = "Blizzard",
        ["Fusion"] = "Fire",
        -- LEVEL 1
        ["Compression"] = "Aspir",
        ["Liquefaction"] = "Fire",
        ["Induration"] = "Blizzard",
        ["Reverberation"] = "Water",
        ["Transfixion"] = "Banish",
        ["Scission"] = "Stone",
        ["Detonation"] = "Aero",
        ["Impaction"] = "Thunder"
}

-- SPELL TIER ORDER, TO CHANGE THE ORDER SIMPLY MOVE THE NUMERIC VALUES AROUND BETWEEN 1 and 6
TierOrder = {
    [1] = "VI",
    [2] = "V",
    [3] = "IV",
    [4] = "III",
    [5] = "II",
    [6] = "I"
}

-- AS ASHITA DOES NOT HAVE A CURRENT WAY TO READ JP OUTSIDE OF PACKET READING ( WHICH REQUIRES ZONING TO VIEW ) YOU MUST EDIT THIS TO ENABLE JOB POINT SPELLS
JobPoints_SPENT = {-- MAKE SURE TO ADD YOUR JOB TO THIS TABLE IF IT DOES NOT CURRENTLY EXIST
    ["WHM"] = 0, -- WHITE MAGE
    ["BLM"] = 0, -- BLACK MAGE
    ["RDM"] = 0, -- RED MAGE
    ["SMN"] = 0, -- SUMMONER ( not yet implemented )
    ["BLU"] = 0, -- BLUE MAGE ( not yet implemented )
    ["SCH"] = 0, -- SCHOLAR
    ["GEO"] = 0 -- GEOMANCER
}

-- SPECIFY THE THREE LETTER NAME OF THE JOBS YOU WANT TO ENABLE BURSTING ON
BurstJobs = {'RDM', 'SCH', 'BLM', 'GEO'}


-- ENABLE DEBUG MODE (WILL SHOW MESSAGES INDICATING EACH STAGE. USEFUL FOR FINDING WHERE THE PROGRAM STALLS.
DebugMode = false

-- IF THE BOT DOESN'T ACTIVATE CORRECTLY (EX. SPELL DOESN'T GET CAST) TRY EXTENDING THE DELAY IN SECONDS BELOW
ExtendedDelay = 0
