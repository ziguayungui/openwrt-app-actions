
module("luci.controller.pikvm", package.seeall)

function index()
  entry({"admin", "services", "pikvm"}, alias("admin", "services", "pikvm", "config"), _("PiKVM"), 30).dependent = true
  entry({"admin", "services", "pikvm", "config"}, cbi("pikvm"))
end
