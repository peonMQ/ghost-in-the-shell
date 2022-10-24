--- @type Mq
local mq = require('mq')
local packageMan = require('mq/PackageMan')
local configLoader = require('utils/configloader')
local debug = require('utils/debug')

local sqlite3 = packageMan.Require('lsqlite3')


local configDir = (mq.configDir.."/"):gsub("\\", "/"):gsub("%s+", "%%20")
local serverName = mq.TLO.MacroQuest.Server()
local dbFileName = configDir..serverName.."/data/spawnDebuffs.db"
local connectingString = string.format("file:///%s?cache=shared&mode=rwc&_journal_mode=WAL", dbFileName)
local db = sqlite3.open(connectingString, sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE + sqlite3.OPEN_URI)


db:exec[[
  PRAGMA journal_mode=WAL;
  CREATE TABLE IF NOT EXISTS debuffs (
      id INTEGER PRIMARY KEY
      , spawnId INTEGER
      , spellId INTEGER
      , spellCategoryId INTEGER
      , spellSubCategoryId INTEGER
      , expireTimeStamp INTEGER
  );
]]

local function clean()
  local sql = [[
    DELETE FROM debuffs a
      WHERE a.expireTimeStamp < %s
  ]]

  local deleteSQL = sql:format(sql, os.time()-20)
  local retries = 0
  local result = db:exec(deleteSQL)
  while result ~= 0 and retries < 20 do
    mq.delay(10)
    retries = retries + 1
    result = db:exec(deleteSQL)
  end

  if result ~= 0 then
    print("Failed <"..deleteSQL..">")
  end
end

---@param spawnId integer
---@param debuffSpell DeBuffSpell
---@return {id: integer, spellId: integer, spellCategoryId: integer, spellSubCategoryId: integer, expireTimeStamp: integer}[]
local function getDebuffs(spawnId, debuffSpell)
  local sql = [[
    SELECT * FROM debuffs 
      WHERE a.spawnId == %d AND a.spellCategoryId = %d AND a.spellSubCategoryId = %d
  ]]

  local debuffs = {}
  for debuff in db:nrows(sql:format(spawnId, debuffSpell.CategoryId, debuffSpell.SubCategoryId)) do table.insert(debuffs, debuff) end
  return debuffs
end

---@param spawnId integer
---@param debuffSpell DeBuffSpell
local function insert(spawnId, debuffSpell)
  local insertStatement = string.format("INSERT INTO log(spawnId, spellId, spellCategoryId, spellSubCategoryId, expireTimeStamp) VALUES(%d, %d, %d, %d, %d)", spawnId, debuffSpell.Id, debuffSpell.CategoryId, debuffSpell.SubCategoryId, os.time() + debuffSpell.Duration)
  local retries = 0
  local result = db:exec(insertStatement)
  while result ~= 0 and retries < 20 do
    mq.delay(10)
    retries = retries + 1
    result = db:exec(insertStatement)
  end

  if result ~= 0 then
    print("Failed <"..insertStatement..">")
  end
end

local repository = {
  Clean = clean,
  GetDebuffs = getDebuffs,
  Insert = insert
}

return repository