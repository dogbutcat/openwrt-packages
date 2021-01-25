#
# Copyright (C) 2019 OpenWrt.org
#
# KFERMercer <KFER.Mercer@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=MosChinaDNS
PKG_VERSION:=v1.5.6
PKG_RELEASE:=9

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Mos-ChinaDNS is a low laterncy DNS client support DoH/DoT
	URL:=https://github.com/IrineSistiana/mos-chinadns
endef


define Package/$(PKG_NAME)/description
Mos-ChinaDNS is a low laterncy DNS client support DoH/DoT
endef

# 禁止OpenWrt对二进制文件进行strip
STRIP:=true

ifeq ($(ARCH),i386)
	PKG_ARCH_MOSCHINADNS:=86
endif

ifeq ($(ARCH),x86_64)
	PKG_ARCH_MOSCHINADNS:=amd64
endif

ifeq ($(ARCH),mipsel)
	PKG_ARCH_MOSCHINADNS:=mipsle-softfloat
endif

ifeq ($(ARCH),mips)
	PKG_ARCH_MOSCHINADNS:=mipsle-softfloat
endif

ifeq ($(ARCH),arm)
	PKG_ARCH_MOSCHINADNS:=arm-7
endif

ifeq ($(ARCH),aarch64)
	PKG_ARCH_MOSCHINADNS:=arm64
endif


PKG_SOURCE:=mos-chinadns-linux-$(PKG_ARCH_MOSCHINADNS).zip

# https://github.com/IrineSistiana/mos-chinadns/releases/download/v1.0.0-rc1/mos-chinadns-linux-mipsle-softfloat.zip
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mos-chinadns/releases/download/$(PKG_VERSION)/

UNZIP_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)-unzip

PKG_HASH:=skip

define Build/Prepare
	mkdir -vp $(UNZIP_DIR)
	unzip -od $(UNZIP_DIR) $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	mkdir $(1)/usr/bin/$(PKG_NAME)
	$(INSTALL_BIN) $(UNZIP_DIR)/mos-chinadns $(1)/usr/bin/$(PKG_NAME)/$(PKG_NAME)
	$(INSTALL_BIN) $(UNZIP_DIR)/chn.list $(1)/usr/bin/$(PKG_NAME)/chn.list
	$(INSTALL_BIN) $(UNZIP_DIR)/chn_domain.list $(1)/usr/bin/$(PKG_NAME)/chn_domain.list
	chmod 755 $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
