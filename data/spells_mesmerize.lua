---@class MezzSpells
---@field ENC table<CrowdControlMode, string|nil>
---@field BRD table<CrowdControlMode, string|nil>
return {
  ENC = {
    single_mez = "enc_mez",
    ae_mez = "enc_ae_mez",
    unresistable_mez = "enc_unresistable_mez",
  },
  BRD = {
    single_mez = "brd_mez",
    ae_mez = "brd_ae_mez",
    unresistable_mez = nil
  }
}