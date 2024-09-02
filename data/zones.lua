---@alias Continents "Anatonica" | "Kunark" | "Velious" | "Planes"

---@class Zone
---@field name string
---@field shortname string

---@class Continent
---@field name Continents
---@field zones Zone[]

local original = {
  -- apprentice="Designer Apprentice",
  -- arttest="Art Testing core",
  -- aviak="Aviak Village",
  -- barter="The Barter Hall",
  -- bazaar="The Bazaar",
  -- bazaar2="The Bazaar (2)",
  -- clz="Loading (C)",
  -- crafthalls="Ngreth's Den",
  -- dragoncrypt="Lair of the Fallen",
  -- dragonscalea="Tinmizer's Wunderwerks",
  -- fhalls="The Forgotten Halls",
  -- guildlobby="The Guild Lobby",
  -- load="Loading (A)",
  -- load2="Loading (B)",
  -- nedaria="Nedaria's Landing",
  -- nektropos="Nektropos",
  -- poknowledge="Plane of Knowledge",
  -- shadowrest="Shadowrest",
  -- takishruins="Ruins of Takish-Hiz",
  -- tutorial="Tutorial Zone",
  -- tutoriala="The Mines of Gloomingdeep (A)",
  -- tutorialb="The Mines of Gloomingdeep (B)",
  -- weddingchapel="Wedding Chapel",
  -- weddingchapeldark="Wedding Chapel",
}

local anatonica = {
  arena="The Arena (A)",
  arena2="The Arena (B)",
  befallen="Befallen (A)",
  -- befallenb="Befallen (B)",
  beholder="Gorge of King Xorbb",
  blackburrow="BlackBurrow",
  cazicthule="Cazic-Thule",
  -- commonlands="Commonlands",
  commons="West Commonlands",
  eastkarana="East Karana",
  ecommons="East Commonlands",
  everfrost="Everfrost Peaks",
  feerrott="The Feerrott(A)",
  -- freeporteast="East Freeport",
  -- freeportsewers="Freeport Sewers",
  -- freeportwest="West Freeport",
  freporte="East Freeport",
  freportn="North Freeport",
  freportw="West Freeport",
  grobb="Grobb",
  gukbottom="Lower Guk",
  guktop="Upper Guk",
  halas="Halas",
  highkeep="HighKeep",
  highpasshold="Highpass Hold",
  highpasskeep="Highpass Keep",
  innothule="Innothule Swamp (A)",
  innothuleb="Innothule Swamp (B)",
  -- jaggedpine="The Jaggedpine Forest",
  -- kithforest="Kithicor Forest (B)",
  kithicor="Kithicor Forest (A)",
  lakerathe="Lake Rathetear",
  lavastorm="Lavastorm Mountains",
  misty="Misty Thicket (A)",
  -- mistythicket="Misty Thicket (B)",
  najena="Najena",
  nektulos="Nektulos Forest",
  neriaka="Neriak Foreign Quarter",
  neriakb="Neriak Commons",
  neriakc="Neriak Third Gate",
  -- neriakd="Neriak Palace",
  northkarana="North Karana",
  -- northro="North Ro (B)",
  nro="North Ro (A)",
  oasis="Oasis of Marr",
  -- oceanoftears="Ocean Of Tears",
  oggok="Oggok",
  oot="Ocean of Tears",
  paw="Infected Paw",
  permafrost="Permafrost Keep",
  qcat="Qeynos Catacombs",
  qey2hh1="West Karana",
  qeynos="South Qeynos",
  qeynos2="North Qeynos",
  qeytoqrg="Qeynos Hills",
  qrg="Surefall Glade",
  rathemtn="Mountains of Rathe",
  rivervale="Rivervale",
  runnyeye="Clan RunnyEye",
  soldunga="Solusek's Eye",
  soldungb="Nagafen's Lair",
  -- soldungc="The Caverns of Exile",
  soltemple="Temple of Solusek Ro",
  southkarana="South Karana",
  -- southro="South Ro (B)",
  sro="South Ro (A)",
  surefall="Surefall Glade",
}

local faydwer = {
  akanon="Ak'Anon",
  butcher="Butcherblock Mountains",
  cauldron="Dagnor's Cauldron",
  crushbone="Clan Crushbone",
  felwithea="Felwithe (A)",
  felwitheb="Felwithe (B)",
  gfaydark="The Greater Faydark",
  kaladima="Kaladim (A)",
  kaladimb="Kaladim (B)",
  kedge="Kedge Keep",
  lfaydark="The Lesser Faydark",
  mistmoore="Castle Mistmoore",
  steamfont="Steamfont Mountains",
  -- steamfontmts="Steamfont Mountains",
  unrest="Estate of Unrest",
}

local odus = {
  erudnext="Erudin",
  erudnint="Erudin Palace",
  erudsxing="Erud's Crossing",
  -- erudsxing2="Marauder's Mire",
  hole="The Ruins of Old Paineel",
  kerraridge="Kerra Isle",
  paineel="Paineel",
  -- stonebrunt="Stonebrunt Mountains",
  tox="Toxxulia Forest",
  -- toxxulia="Toxxulia Forest",
  -- warrens="The Warrens",
}

local planes = {
  airplane="Plane of Sky",
  fearplane="Plane of Fear",
  hateplane="The Plane of Hate",
  hateplaneb="The Plane of Hate (B)",
}

local kunark = {
  burningwood="Burning Woods",
  cabeast="East Cabilis",
  cabwest="West Cabilis",
  charasis="Howling Stones",
  chardok="Chardok",
  -- chardokb="The Halls of Betrayal",
  citymist="City of Mist",
  dalnir="Dalnir",
  dreadlands="Dreadlands",
  droga="Temple of Droga",
  emeraldjungle="The Emerald Jungle",
  fieldofbone="The Field of Bone",
  firiona="Firiona Vie",
  frontiermtns="Frontier Mountains",
  kaesora="Kaesora",
  karnor="Karnor's Castle",
  kurn="Kurn's Tower",
  lakeofillomen="Lake of Ill Omen",
  nurga="Mines of Nurga",
  overthere="The Overthere",
  sebilis="Old Sebilis",
  skyfire="Skyfire Mountains",
  swampofnohope="Swamp of No Hope",
  timorous="Timorous Deep",
  trakanon="Trakanon's Teeth",
  veeshan="Veeshan's Peak",
  veksar="Veksar",
  warslikswood="Warsliks Wood",
}

local velius = {
}

local div = {
  cshome="CS Home",
  neighborhood = "Sunrise Hills",
}

---@type table<Continents, table<string, string>>
return {
  Anatonica = anatonica,
  Faydwer = faydwer,
  Odus = odus,
  Kunark = kunark,
  Velius = velius,
  Planes = planes,
  Div = div,
}

-- https://replit.com/languages/lua
--[[
local zones = {
  shortname="longname"
}

local keys = {}

for key,_ in pairs(zones) do
  table.insert(keys, key)
end

table.sort(keys, function(a,b) return a > b end)

for _,key in ipairs(keys) do
  print(key..'="'..zones[key]..'"')
end
]]