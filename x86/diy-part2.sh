#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/9.9.9.2/g' package/base-files/files/bin/config_generate

# Themes 主题
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 修改 argon 为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/diy/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 修改欢迎banner
cp -f $GITHUB_WORKSPACE/diy/banner package/base-files/files/etc/banner

# 显示增加编译时间
sed -i "s/<%=pcdata(ver.distname)%> <%=pcdata(ver.distversion)%>/<%=pcdata(ver.distname)%> <%=pcdata(ver.distversion)%> (By @TIAmo build $(TZ=UTC-8 date "+%Y-%m-%d %H:%M"))/g" package/lean/autocore/files/x86/index.htm

# 修改概览里时间显示为中文数字
sed -i 's/os.date()/os.date("%Y年%m月%d日") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")/g' package/lean/autocore/files/x86/index.htm

# Git稀疏克隆，只克隆指定目录到本地
        function git_sparse_clone() {
          branch="$1" rurl="$2" localdir="$3" && shift 3
          git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
          if [ "$?" != 0 ]; then
            echo "error on $rurl"
            pid="$( ps -q $$ )"
            kill $pid
          fi
          cd $localdir
          git sparse-checkout init --cone
          git sparse-checkout set $@
          mv -n $@ ../ || true
          cd ..
          rm -rf $localdir
          }
        function git_sparse_clone2() {
          commitid="$1" rurl="$2" localdir="$3" && shift 3
          git clone --filter=blob:none --sparse $rurl $localdir
          cd $localdir
          git checkout $commitid
          git sparse-checkout init --cone
          git sparse-checkout set $@
          mv -n $@ ../ || true
          cd ..
          rm -rf $localdir
          }
        function mvdir() {
        mv -n `find $1/* -maxdepth 0 -type d` ./
        rm -rf $1
        }

# 添加额外插件
git_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git_clone https://github.com/xiaorouji/openwrt-passwall-packages && mvdir openwrt-passwall-packages
git_clone main https://github.com/fw876/helloworld && mvdir helloworld
git_clone https://github.com/xiaorouji/openwrt-passwall openwrt-passwall/luci-app-passwall
