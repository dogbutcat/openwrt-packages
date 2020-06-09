#
# Copyright (c) 2017 Yu Wang <wangyucn@gmail.com>
#
# This is free software, licensed under the MIT.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=speederv2-tunnel
PKG_VERSION:=20190121.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/wangyu-/UDPspeeder.git
# PKG_SOURCE_VERSION:=ecc90928d33741dbe726b547f2d8322540c26ea0 # latest
PKG_SOURCE_VERSION:=f0a7b28a63505edbb4f89163bb10ad992c57e657
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz

PKG_MAINTAINER:=Yu Wang

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Tunnel which speed up udp packages
	URL:=https://github.com/wangyu-/UDPspeeder
endef

define Package/$(PKG_NAME)/description
	udpspeeder-tunnel is a tunnel which speed up udp package.
endef

ifneq ($(ARCH), $(filter $(ARCH), x86_64, 386))
	MAKE_FLAGS += cross2
	OUT_FILE:=$(PKG_BUILD_DIR)/speederv2_cross
else
	OUT_FILE:=$(PKG_BUILD_DIR)/speederv2
endif

define Build/Configure
	$(call Build/Configure/Default)
	$(SED) 's/cc_cross[[:space:]]*=.*/cc_cross=$(TARGET_CXX)/' \
		-e 's/\\".*shell git rev-parse HEAD.*\\"/\\"$(PKG_SOURCE_VERSION)\\"/' \
		$(PKG_BUILD_DIR)/makefile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(OUT_FILE) $(1)/usr/bin/speederv2
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
