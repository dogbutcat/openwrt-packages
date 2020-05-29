local fs=require"nixio.fs"
local uci=require"luci.model.uci".cursor()
local f,t
f=SimpleForm("logview")
f.reset = false
f.submit = false
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=20
t.template="MosChinaDNS/log"
t.readonly="readonly"
local logfile=uci:get("MosChinaDNS","MosChinaDNS","logfile") or ""
t.timereplace=(logfile~="syslog" and logfile~="" )
t.pollcheck=logfile~=""
fs.writefile("/var/run/lucilogreload","")
return f
