

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.0.2-20231208
PKG_RELEASE:=

LUCI_TITLE:=LuCI support for PiKVM
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +luci-lib-taskd +luci-lib-docker +kmod-usb-serial-ch341

define Package/luci-app-pikvm/conffiles
/etc/config/pikvm
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
