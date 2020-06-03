#
# Copyright (C) 2019 OpenWrt.org
#
# KFERMercer <KFER.Mercer@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=speederv2
PKG_VERSION:=20190121.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=udp speederv2 is for udp speed up
	URL:=https://github.com/wangyu-/UDPspeeder
endef


define Package/$(PKG_NAME)/description
Mos-ChinaDNS is a low laterncy DNS client support DoH/DoT
endef

# 禁止OpenWrt对二进制文件进行strip
STRIP:=true

ifeq ($(ARCH),i386)
	PKG_ARCH_SPEEDERV2:=x86
endif

ifeq ($(ARCH),x86_64)
	PKG_ARCH_SPEEDERV2:=amd64
endif

ifeq ($(ARCH),mipsel)
	PKG_ARCH_SPEEDERV2:=mips24kc_be
endif

ifeq ($(ARCH),mips)
	PKG_ARCH_SPEEDERV2:=mips24kc_le
endif

ifeq ($(ARCH),arm)
	PKG_ARCH_SPEEDERV2:=arm
endif

ifeq ($(ARCH),aarch64)
	PKG_ARCH_SPEEDERV2:=arm64
endif


PKG_SOURCE:=speederv2_binaries.tar.gz

# https://github.com/wangyu-/UDPspeeder/releases/download/20190121.0/speederv2_binaries.tar.gz
PKG_SOURCE_URL:=https://github.com/wangyu-/UDPspeeder/releases/download/$(PKG_VERSION)/

UNTAR_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)-extract/$(PKG_ARCH_SPEEDERV2)

PKG_HASH:=skip

define Build/Prepare
	mkdir -vp $(UNTAR_DIR)
	tar -zxvf $(DL_DIR)/$(PKG_SOURCE) -C $(UNTAR_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(UNTAR_DIR)/speederv2_$(PKG_ARCH_SPEEDERV2) $(1)/usr/bin/$(PKG_NAME)
	chmod +x $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
