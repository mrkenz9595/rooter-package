#Owned by DairyMan@Whirlpool
#
#Copyright GNU act.
include $(TOPDIR)/rules.mk

PKG_NAME:=ext-rooter-lite
PKG_VERSION:=1.000
PKG_RELEASE:=1

PKG_MAINTAINER:=Created by DM/makefile by Cobia@whirlpool
include $(INCLUDE_DIR)/package.mk

define Package/ext-rooter-lite
  SECTION:=utils
  CATEGORY:=ROOter
  DEPENDS:=+luci +ext-rooter-basic \
		+luci-app-ddns +ddns-scripts +ddns-scripts_no-ip_com \
		+webconsole +bwmon \
		+ext-theme +luci-theme-argon +argon-config +ext-login \
		+luci-theme-tomato +ext-material \
		+ca-bundle +ca-certificates +libustream-openssl \
		+luci-app-sqm +kmod-sched-cake \
		+ext-command +ext-speedtest +luci-app-guestwifi \
		+ext-extra +luci-app-hotspot +luci-app-wol \
		+usbmuxd +libusbmuxd-utils +libimobiledevice-utils +kmod-usb-net-ipheth \
		+nano +picocom +wpad +wget +qfirehose 
  TITLE:=ROOter support w/o MWan3 for 16meg and larger routers w/o MWan3
  PKGARCH:=all
endef

define Package/ext-rooter-lite/description
  Helper scripts to enable ROOter support w/o MWan3 on 16meg and larger routers w/o MWan3
endef


define Build/Compile
endef

$(eval $(call BuildPackage,ext-rooter-lite))
