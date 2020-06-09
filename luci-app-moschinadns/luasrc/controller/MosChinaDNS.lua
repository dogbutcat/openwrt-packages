module("luci.controller.MosChinaDNS",package.seeall)
local fs=require"nixio.fs"
local http=require"luci.http"
local uci=require"luci.model.uci".cursor()
function index()
entry({"admin", "services", "MosChinaDNS"},alias("admin", "services", "MosChinaDNS", "base"),_("Mos ChinaDNS"), 10).dependent = true
entry({"admin","services","MosChinaDNS","base"},cbi("MosChinaDNS/base"),_("Base Setting"),1).leaf = true
entry({"admin","services","MosChinaDNS","log"},form("MosChinaDNS/log"),_("Log"),2).leaf = true
entry({"admin","services","MosChinaDNS","manual"},cbi("MosChinaDNS/manual"),_("Manual Config"),3).leaf = true
entry({"admin","services","MosChinaDNS","status"},call("act_status")).leaf=true
entry({"admin", "services", "MosChinaDNS", "check"}, call("check_update"))
entry({"admin", "services", "MosChinaDNS", "doupdate"}, call("do_update"))
entry({"admin", "services", "MosChinaDNS", "getlog"}, call("get_log"))
entry({"admin", "services", "MosChinaDNS", "dodellog"}, call("do_dellog"))
entry({"admin", "services", "MosChinaDNS", "reloadconfig"}, call("reload_config"))
entry({"admin", "services", "MosChinaDNS", "gettemplateconfig"}, call("get_template_config"))
entry({"admin", "services", "MosChinaDNS", "doupdatelist"}, call("do_update_list"))
entry({"admin", "services", "MosChinaDNS", "checkupdatelist"}, call("check_update_list"))
end 
function get_template_config()
	local b
	local d=""
	for cnt in io.lines("/tmp/resolv.conf.auto") do
		b=string.match (cnt,"^[^#]*nameserver%s+([^%s]+)$")
		if (b~=nil) then
			d=d.."  - "..b.."\n"
		end
	end
	local f=io.open("/usr/share/MosChinaDNS/MosChinaDNS_template.yaml", "r+")
	local tbl = {}
	local a=""
	while (1) do
    	a=f:read("*l")
		if (a=="#bootstrap_dns") then
			a=d
		elseif (a=="#upstream_dns") then
			a=d
		elseif (a==nil) then
			break
		end
		table.insert(tbl, a)
	end
	f:close()
	http.prepare_content("text/plain; charset=utf-8")
	http.write(table.concat(tbl, "\n"))
end
function reload_config()
	fs.remove("/tmp/MosChinaDNStmpconfig.yaml")
	http.prepare_content("application/json")
	http.write('')
end
function act_status()
	local e={}
	local binpath=uci:get("MosChinaDNS","MosChinaDNS","binpath")
	e.running=luci.sys.call("pgrep "..binpath.." >/dev/null")==0
	e.redirect=(fs.readfile("/var/run/MCDredir")=="1")
	http.prepare_content("application/json")
	http.write_json(e)
end
function do_update()
	fs.writefile("/var/run/lucilogpos","0")
	http.prepare_content("application/json")
	http.write('')
	local arg
	if luci.http.formvalue("force") == "1" then
		arg="force"
	else
		arg=""
	end
	if fs.access("/var/run/update_moschinadns_core") then
		if arg=="force" then
			luci.sys.exec("kill $(pgrep /usr/share/MosChinaDNS/update_moschinadns_core.sh) ; sh /usr/share/MosChinaDNS/update_moschinadns_core.sh "..arg.." >/tmp/MosChinaDNS_update.log 2>&1 &")
		end
	else
		luci.sys.exec("sh /usr/share/MosChinaDNS/update_moschinadns_core.sh "..arg.." >/tmp/MosChinaDNS_update.log 2>&1 &")
	end
end
function get_log()
	local logfile=uci:get("MosChinaDNS","MosChinaDNS","logfile")
	if (logfile==nil) then
		http.write("no log available\n")
		return
	elseif (logfile=="syslog") then
		if not fs.access("/var/run/MosChinaDNSsyslog") then
			luci.sys.exec("(/usr/share/MosChinaDNS/getsyslog.sh &); sleep 1;")
		end
		logfile="/tmp/MosChinaDNStmp.log"
		fs.writefile("/var/run/MosChinaDNSsyslog","1")
	elseif not fs.access(logfile) then
		http.write("")
		return
	end
	http.prepare_content("text/plain; charset=utf-8")
	local fdp
	if fs.access("/var/run/lucilogreload") then
		fdp=0
		fs.remove("/var/run/lucilogreload")
	else
		fdp=tonumber(fs.readfile("/var/run/lucilogpos")) or 0
	end
	local f=io.open(logfile, "r+")
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/var/run/lucilogpos",tostring(fdp))
	f:close()
	http.write(a)
end
function do_dellog()
	local logfile=uci:get("MosChinaDNS","MosChinaDNS","logfile")
	fs.writefile(logfile,"")
	http.prepare_content("application/json")
	http.write('')
end
function check_update()
	http.prepare_content("text/plain; charset=utf-8")
	local fdp=tonumber(fs.readfile("/var/run/lucilogpos")) or 0
	local f=io.open("/tmp/MosChinaDNS_update.log", "r+")
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/var/run/lucilogpos",tostring(fdp))
	f:close()
if fs.access("/var/run/update_moschinadns_core") then
	http.write(a)
else
	http.write(a.."\0")
end
end
function do_update_list()
	luci.sys.exec("sh /usr/share/MosChinaDNS/update_list.sh >/tmp/MosChinaDNS_update_list.log 2>&1  &")
end
function check_update_list()
	http.prepare_content("text/plain; charset=utf-8")
	local fdp=tonumber(fs.readfile("/var/run/lucilogpos")) or 0
	local f=io.open("/tmp/MosChinaDNS_update_list.log", "r+")
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/var/run/lucilogpos",tostring(fdp))
	f:close()
if fs.access("/var/run/update_list") then
	http.write(a)
else
	if fs.access("/var/run/update_list_error") then
		local ferr=io.open("/var/run/update_list_error", "r+")
		a=ferr:read()
		ferr:close()
		http.write(a)
	else
		http.write(a.."\0")
	end
end
end