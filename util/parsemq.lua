local mq = require('mq')

local TLOMembers = {
  'Achievement',
  'AltAbility',
  'Bandoliler',
  'Corpse',
  'Cursor',
  'DisplayItem',
  'Me',
  'Group',
  'EverQuest',
}

local function printMemberItem(index, member, memberType, memberValue)
   print(string.format('%d. %s (%s) [%s]', index, member, memberType, tostring(memberValue)))
end

local function listMembers(tlo, dataTypePath, datatype)
   local index = 0
   if not mq.TLO.Type(datatype).Member(index)() then
    index = 1
   end

   while mq.TLO.Type(datatype).Member(index)() do
      local member = mq.TLO.Type(datatype).Member(index)()
      local memberType = mq.gettype(tlo[member])
      local memberValue = nil
      if dataTypePath then
         memberValue = tlo[dataTypePath][member]()
      else
         memberValue = tlo[member]()
      end
      printMemberItem(index, member, memberType, memberValue)
      listMembers(member, memberType)
      index = index + 1
   end
end

local function listTLO()
  for k, member in ipairs (TLOMembers) do
    local tloMember = mq.TLO[member]
    local tloMemberType = mq.gettype(tloMember)
    print(string.format('Starting [mq.TLO.%s] with datatype <%s>', member, tloMemberType))
    listMembers(tloMember, nil, tloMemberType)
  end
end

listTLO()