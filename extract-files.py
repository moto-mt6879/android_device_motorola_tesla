#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/motorola/mt6879-common',
    'vendor/motorola/mt6879-common',
    'device/motorola/tesla',
    'hardware/mediatek',
    'hardware/mediatek/libaedv',
    'hardware/motorola',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
}

blob_fixups: blob_fixups_user_type = {
    'vendor/lib64/hw/audio.primary.mediatek.so': blob_fixup()
        .add_needed('libstagefright_foundation-v33.so')
        .replace_needed('libutils.so','libutils-v32.so')
        .replace_needed('libtinyxml2.so', 'libtinyxml2-v31.so')
        .replace_needed('libalsautils.so','libalsautils-v31.so'),
    ('vendor/lib64/hw/mt6879/android.hardware.camera.provider@2.6-impl-mediatek.so', 'vendor/lib64/mt6879/libmtkcam_stdutils.so'): blob_fixup()
        .replace_needed('libutils.so', 'libutils-v32.so'),
    ('vendor/lib64/mt6879/lib3a.flash.so', 'vendor/lib64/mt6879/lib3a.ae.stat.so',
     'vendor/lib64/mt6879/lib3a.sensors.flicker.so', 'vendor/lib64/mt6879/lib3a.sensors.color.so',
     'vendor/lib64/lib3a.ae.pipe.so'): blob_fixup()
        .add_needed('liblog.so'),
    'vendor/lib64/libstfactory-vendor.so': blob_fixup()
        .add_needed('libbase_shim.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'tesla',
    'motorola',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
    add_firmware_proprietary_file=True,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'mt6879-common', module.vendor
    )
    utils.run()
