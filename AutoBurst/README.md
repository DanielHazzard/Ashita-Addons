## AutoBurst Windower Addon v1.0 Beta
### Automatically Bursts when it reads a SKILLCHAIN packet

---

#### UPDATES AND MODIFICATIONS
##### version 1.2
Changed targeting to use the PACKET TARGET id.

##### version 1.1
Added PET recognition.


#### SET UP
Place the Folder AutoBurst inside the Ashita/Addons/ directory should look similar too

```
Ashita/
     Addons/
          AutoBurst
               AutoBurst.lua
               AutoBurst_config.lua
```


#### MODIFICATIONS AND SETUP

After placing the files in the correct directory, while in game to begin the bot type the following in game.
***/addon load AutoBurst***

With this done the addon should not be ready to work, simply begin skillchaining and 2 seconds after the chain your character wil begin bursting. Please note only the following jobs will burst: RDM, BLM, SCH, or GEO, going forward I'll extend this list.


#### ADVANCED SET UP
Advanced setup allows you to edit Elements to burst with and tiers. The settings are customised in AutoBurst_config.lua, in the LUA the additional customizable options are

```
burstMagic = {
  -- LEVEL 3  and 4
  ["radiance"] = "Thunder",
  ["light"] = "Thunder",
  ["umbra"] = "Blizzard",
  ["darkness"] = "Blizzard",
  -- LEVEL 2
  ["gravitation"] = "Stone",
  ["fragmentation"] = "Thunder",
  ["distortion"] = "Blizzard",
  ["fusion"] = "Fire",
  -- LEVEL 1
  ["compression"] = "Aspir",
  ["liquefaction"] = "Fire",
  ["induration"] = "Blizzard",
  ["reverberation"] = "Water",
  ["transfixion"] = "Banish",
  ["scission"] = "Stone",
  ["detonation"] = "Aero",
  ["impaction"] = "Thunder",
}

tierOrder = {
  [1] = "VI",
  [2] = "V",
  [3] = "IV",
  [4] = "III",
  [5] = "II",
  [6] = "I",
}
```

To edit elements simply change the current element to a different one, for example.

```
["radiance"] = "Fire",
```

To edit Tiers, simply change the tier number, for example.

```
  [4] = "VI",
  [3] = "V",
  [2] = "IV",
  [1] = "III",
  [5] = "II",
  [6] = "I",
```

This will then make the addon check and use spells in the following order.

III, IV, V, VI, II, I




