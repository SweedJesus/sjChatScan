sjChatScan = AceLibrary("AceAddon-2.0"):new(
"AceConsole-2.0",
"AceDebug-2.0",
"AceDB-2.0",
"AceEvent-2.0")

local this = sjChatScan

local channel  = "CHAT_MSG_CHANNEL"
local guild    = "CHAT_MSG_GUILD"
local officer  = "CHAT_MSG_OFFICER"
local party    = "CHAT_MSG_PARTY"
local raid     = "CHAT_MSG_RAID"
local say      = "CHAT_MSG_SAY"
local whisper  = "CHAT_MSG_WHISPER"
local yell     = "CHAT_MSG_YELL"

local function Notify(msg)
    UIErrorsFrame:AddMessage(msg)
end

--- Color table to hex string.
local function ColorToHex(color)
    local r, g, b = color.r*255, color.g*255, color.b*255
    return string.format("%.2x%.2x%.2x", r, g, b)
end

--- Substring highlighter.
-- Returns a copy of a message with a substring highlighted.
local function Highlight(message, s, e, color)
    local new = ""
    if s > 1 then
        new = string.sub(message, 1, s-1)
    end
    new = new.."|cff"..ColorToHex(color)..string.sub(message, s, e).."|r"
    if e < string.len(message) then
        new = new..string.sub(message, e+1)
    end
    return new
end

--- Channel getter closure generator.
local function MakeChannelGetter(self, channel)
    return function()
        return self.channels[channel]
    end
end

--- Channel setter closure generator.
local function MakeChannelSetter(self, channel)
    return function(set)
        self.channels[channel] = set
        local registered = self:IsEventRegistered(channel)
        if set and not registered then
            self:Debug("Registered channel "..channel)
            self:RegisterEvent(channel, "OnChatMsg")
        elseif registered then
            self:Debug("Unregistered channel "..channel)
            self:UnregisterEvent(channel)
        end
    end
end

--- Addon initialized handler.
function this:OnInitialize()
    -- Initialize default and options tables
    self:Init()

    -- Saved variables
    self:RegisterDB("sjChatScan_DB")
    self:RegisterDefaults("char", self.defaults)
    self.opt = self.db.char
    self.channels = self.opt.channels
    self.patterns = self.opt.patterns

    -- Slash command
    self:RegisterChatCommand({ "/sjChatScan", "/sjcs" }, self.options)
end

--- Addon enabled handler.
function this:OnEnable()
    for channel,enable in self.channels do
        if enable then
            self:RegisterEvent(channel, "OnChatMsg")
        end
    end
end

--- Addon disabled handler.
function this:OnDisable()
end

--- Chat message handler.
function this:OnChatMsg(message, sender)
    local lower, i, pattern, s, e = string.lower(message), 0
    while not s and i < getn(self.patterns) do
        i = i + 1
        pattern = self.patterns[i]
        s, e = string.find(lower, pattern)
    end
    if s then
        self:Debug("Scan match (pattern:%q s:%d e:%d)", pattern, s, e)
        Notify(string.format("%s: %s", sender, Highlight(message, s, e, self.opt.color)))
    end
end

function this:AddPattern(index, pattern)
    if not pattern then
        pattern = index
    end
    local valid = pcall(string.find, "", pattern)
    if valid then
        self:Print("Added pattern %q", pattern)
        table.insert(self.patterns, pattern)
    else
        self:Print("|cffff0000Error|r Invalid pattern")
    end
end

--- Initialize tables.
function this:Init()
    self.defaults = {
        color = { r = 1, g = 0, b = 1 },
        channels = {
            [channel] = true,
            [guild]   = true,
            [officer] = true,
            [party]   = true,
            [raid]    = true,
            [say]     = true,
            [whisper] = true,
            [yell]    = true
        },
        patterns = {
            string.lower(GetUnitName("player"))
        }
    }

    self.options = {
        type = "group",
        args = {
            channels = {
                name = "Channels",
                desc = "Toggle channels to scan",
                type = "group",
                args = {
                    channel = {
                        name = "Channel",
                        desc = "Toggle world or custom channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, channel),
                        set = MakeChannelSetter(self, channel)
                    },
                    guild = {
                        name = "Guild",
                        desc = "Toggle guild channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, guild),
                        set = MakeChannelSetter(self, guild)
                    },
                    officer = {
                        name = "Officer",
                        desc = "Toggle officer channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, officer),
                        set = MakeChannelSetter(self, officer)
                    },
                    party = {
                        name = "Party",
                        desc = "Toggle party channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, party),
                        set = MakeChannelSetter(self, party)
                    },
                    raid = {
                        name = "Raid",
                        desc = "Toggle raid channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, raid),
                        set = MakeChannelSetter(self, raid)
                    },
                    say = {
                        name = "Say",
                        desc = "Toggle say channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, say),
                        set = MakeChannelSetter(self, say)
                    },
                    whisper = {
                        name = "Whisper",
                        desc = "Toggle whisper channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, whisper),
                        set = MakeChannelSetter(self, whisper)
                    },
                    yell = {
                        name = "Yell",
                        desc = "Toggle yell channel scanning",
                        type = "toggle",
                        get = MakeChannelGetter(self, yell),
                        set = MakeChannelSetter(self, yell)
                    }
                }
            },
            patterns = {
                name = "Patterns",
                desc = "Configure search patterns",
                type = "group",
                args = {
                    list = {
                        name = "List",
                        desc = "List patterns",
                        type = "execute",
                        func = function()
                            -- Maybe make each pattern a different color in spectrum
                            local s = ""
                            for i,v in ipairs(self.patterns) do
                                s = s..string.format('(%s:%q) ', i, string.gsub(v, "%%", "%%%%"))
                            end
                            self:Print(s)
                        end
                    },
                    add = {
                        name = "Add",
                        desc = "Add pattern",
                        type = "text",
                        usage = "<pattern> or <index, pattern>",
                        get = false,
                        set = function(index, pattern)
                            self:AddPattern(index, pattern)
                        end
                    },
                    remove = {
                        name = "Remove",
                        desc = "Remove pattern via index",
                        type = "text",
                        usage = "<index>",
                        get = false,
                        set = function(index)
                            index = tonumber(index)
                            if index <= getn(self.patterns) then
                                self:Print("Removed index %d (%q)", index, self.patterns[index])
                                table.remove(self.patterns, index)
                            else
                                self:Print("|cffff0000Error|r Index %d does not exist", index)
                            end
                        end
                    }
                }
            },
            color = {
                name = "Color",
                desc = "Set highlight color",
                type = "color",
                get = function()
                    local c = self.opt.color
                    return c.r, c.g, c.b
                end,
                set = function(r, g, b)
                    local c = self.opt.color
                    c.r, c.g, c.b = r, g, b
                end
            }
        }
    }
end
