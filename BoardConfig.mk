#
# Copyright (C) The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/motorola/tesla

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := tesla

# DTBO
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img

# Kernel
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules/modules.load.recovery))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules/modules.load.vendor_ramdisk))
BOOT_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD) $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)

# Partitions
BOARD_SUPER_PARTITION_SIZE := 7507804160
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 7305808160

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Security patch level
BOOT_SECURITY_PATCH := 2026-06-01
VENDOR_SECURITY_PATCH := 2026-06-01

# SKU
ODM_MANIFEST_SKUS += be de bn dn
ODM_MANIFEST_BE_FILES := $(DEVICE_PATH)/sku/manifest_be.xml
ODM_MANIFEST_DE_FILES := $(DEVICE_PATH)/sku/manifest_de.xml
ODM_MANIFEST_BN_FILES := $(DEVICE_PATH)/sku/manifest_bn.xml
ODM_MANIFEST_DN_FILES := $(DEVICE_PATH)/sku/manifest_dn.xml

# VINTF
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Verified Boot
BOARD_AVB_ROLLBACK_INDEX := 30
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 30

# Inherit from mt6879-common
include device/motorola/mt6879-common/BoardConfigCommon.mk

# Inherit the proprietary files
include vendor/motorola/tesla/BoardConfigVendor.mk
