--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local m, s, o

m = taskd.docker_map("pikvm", "pikvm", "/usr/libexec/istorec/pikvm.sh",
	translate("PiKVM"),
	translate("PiKVM - Open and inexpensive DIY IP-KVM on Raspberry Pi. ")
		.. translate("Official website:") .. ' <a href=\"https://www.pikvm.org/\" target=\"_blank\">https://www.pikvm.org/</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("PiKVM status:"))
s:append(Template("pikvm/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "port", translate("Https Port").."<b>*</b>")
o.default = "8443"
o.datatype = "port"

o = s:option(Value, "hid", translate("USBHid").."<b>*</b>")
o.default = "/dev/ttyUSB0"
o.datatype = "string"

o = s:option(Value, "video", translate("USBVideo0").."<b>*</b>")
o.default = "/dev/video0"
o.datatype = "string"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o.default = "ziguayungui/pikvm-docker-x86:v3.308"
o:value("ziguayungui/pikvm-docker-x86:v3.308", "ziguayungui/pikvm-docker-x86:v3.308")

return m
