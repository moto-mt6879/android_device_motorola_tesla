#
# Copyright (C) The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/motorola/tesla

# Dalvik
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=24m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.46 \
    dalvik.vm.heapminfree=8m \
    dalvik.vm.heapmaxfree=48m

# Init
PRODUCT_PACKAGES += \
    init.mmi.overlay.rc \
    init.oem.fingerprint2.sh

# Fingerprint
PRODUCT_PACKAGES += \
    libudfpshandler

# Keylayout
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/keylayout/goodix_ts.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/goodix_ts.kl

# MotoActions
PRODUCT_PACKAGES += \
    MotoActionsTesla

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    android.hardware.secure_element-service.nxp

PRODUCT_PACKAGES += \
    com.android.nfc_extras \
    libchrome.vendor \
    Tag

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml

DEVICE_NFC_SKUS := be de bn dn

PRODUCT_COPY_FILES += \
    $(foreach DEVICE_NFC_SKU, $(DEVICE_NFC_SKUS), \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_NFC_SKU)/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_$(DEVICE_NFC_SKU)/android.hardware.se.omapi.ese.xml)

# Powershare
PRODUCT_PACKAGES += \
    vendor.lineage.powershare-service.default

$(call soong_config_set,lineage_powershare,powershare_path,/sys/class/power_supply/wireless/device/tx_mode)

# Public Libraries
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

PRODUCT_PACKAGES += \
    FrameworkOverlayTesla \
    RegulatoryOverlayXT2205-1 \
    RegulatoryOverlayXT2205-2 \
    RegulatoryOverlayXT2205-3

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    hardware/motorola \
    hardware/mediatek/libaedv

# Inherit from mt6879-common
$(call inherit-product, device/motorola/mt6879-common/mt6879.mk)

# Inherit the proprietary files
$(call inherit-product, vendor/motorola/tesla/tesla-vendor.mk)
