local mq = require('mq')
local packageMan = require('mq/PackageMan')
local logger = require('knightlinc/Write')

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

local deleteStmt = assert(
  db:prepare([[
    DELETE FROM debuffs WHERE expireTimeStamp < ?
  ]]),
  db:errmsg()
)

local function clean()
  db:exec("BEGIN IMMEDIATE")
  while true do
    deleteStmt:reset()
    deleteStmt:bind_values(mq.gettime() - 20)
    local rc = deleteStmt:step()
    if rc == sqlite3.DONE then
      logger.Info("Completed clearing debuffs")
      db:exec("COMMIT")
      return true
    end

    if rc == sqlite3.BUSY or rc == sqlite3.LOCKED then
      mq.delay(5) -- short backoff
    else
      logger.Error("DELETE failed (%s): %s", tostring(rc), db:errmsg())
      db:exec("COMMIT")
      return false
    end
  end
end

local selectStmt = assert(
    db:prepare([[
      SELECT *
      FROM debuffs
      WHERE spawnId = ?
        AND spellCategoryId = ?
        AND spellSubCategoryId = ?
    ]]),
    db:errmsg()
  )

---@param spawnId integer
---@param debuffSpell DeBuffSpell
---@return {id: integer, spellId: integer, spellCategoryId: integer, spellSubCategoryId: integer, expireTimeStamp: integer}[]
local function getDebuffs(spawnId, debuffSpell)
  db:exec("BEGIN IMMEDIATE")
  local debuffs = {}
  while true do
    selectStmt:reset()
    selectStmt:bind_values(
      spawnId,
      debuffSpell.CategoryId,
      debuffSpell.SubCategoryId
    )

    debuffs = {}

    while true do
      local rc = selectStmt:step()

      if rc == sqlite3.ROW then
        debuffs[#debuffs + 1] = selectStmt:get_named_values()

      elseif rc == sqlite3.DONE then
        db:exec("COMMIT")
        return debuffs

      elseif rc == sqlite3.BUSY or rc == sqlite3.LOCKED then
        mq.delay(5) -- short backoff
        break -- retry from outer loop

      else
        logger.Error("SELECT failed (%s): %s", tostring(rc), db:errmsg())
        db:exec("COMMIT")
        return debuffs
      end
    end
  end
end


local insertStmt = assert(
  db:prepare([[
    INSERT INTO debuffs (
      spawnId,
      spellId,
      spellCategoryId,
      spellSubCategoryId,
      expireTimeStamp
    ) VALUES (?, ?, ?, ?, ?)
  ]]),
  db:errmsg()
)

---@param spawnId integer
---@param debuffSpell DeBuffSpell
local function insert(spawnId, debuffSpell)
  db:exec("BEGIN IMMEDIATE")
  while true do
    insertStmt:reset()
    insertStmt:bind_values(
      spawnId,
      debuffSpell.Id,
      debuffSpell.CategoryId,
      debuffSpell.SubCategoryId,
      mq.gettime() + debuffSpell.RefreshTimer
    )

    local rc = insertStmt:step()

    if rc == sqlite3.DONE then
      db:exec("COMMIT")
      return true

    elseif rc == sqlite3.BUSY or rc == sqlite3.LOCKED then
      mq.delay(10) -- short backoff

    else
      logger.Error(
        "INSERT debuff failed (%s): %s",
        tostring(rc),
        db:errmsg()
      )
      db:exec("COMMIT")
      return false
    end
  end
end

local repository = {
  Clean = clean,
  GetDebuffs = getDebuffs,
  Insert = insert
}

return repository