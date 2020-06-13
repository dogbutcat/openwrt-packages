# Copyright (C) 2018-2019 Lienol
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-moschinadns
PKG_VERSION:=1.1
PKG_RELEASE:=22

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-moschinadns
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI app for moschinadns
	PKG_MAINTAINER:=<https://github.com/dogbutcat/luci-app-moschinadns>
	PKGARCH:=all
	DEPENDS:= \
		+MosChinaDNS \
		+!wget&&!curl:wget
endef

define Package/luci-app-moschinadns/description
	LuCI support for moschinadns
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/luci-app-moschinadns/conffiles
/usr/share/MosChinaDNS/links.txt
/etc/config/MosChinaDNS
endef

define Package/luci-app-moschinadns/install
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/MosChinaDNS.po $(1)/usr/lib/lua/luci/i18n/MosChinaDNS.zh-cn.lmo
endef

define Package/luci-app-moschinadns/postinst
#!/bin/sh
	/etc/init.d/MosChinaDNS enable >/dev/null 2>&1
	enable=$(uci get MosChinaDNS.MosChinaDNS.enabled 2>/dev/null)
	if [ "$enable" == "1" ]; then
		/etc/init.d/MosChinaDNS reload
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/luci-app-moschinadns/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/MosChinaDNS disable
     /etc/init.d/MosChinaDNS stop
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@MosChinaDNS[-1]
	commit ucitrack
EOF
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-moschinadns))
