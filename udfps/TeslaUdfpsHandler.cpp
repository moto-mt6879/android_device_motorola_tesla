/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "libudfpshandler"

#include "UdfpsHandler.h"
#include <android-base/logging.h>
#include <drm/mediatek_drm.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <sys/ioctl.h>
#include <mutex>

enum HBM_STATE { OFF = 0, ON = 2 };

namespace {
void setHbmState(int state) {
    struct panel_param_info param_info;
    int32_t node = open("/dev/dri/card0", O_RDWR);
    int32_t ret = 0;

    if (node < 0) {
        LOG(ERROR) << "Failed to get card0!";
        return;
    }

    param_info.param_idx = PARAM_HBM;
    param_info.value = state;

    ret = ioctl(node, DRM_IOCTL_SET_PANEL_FEATURE, &param_info);
    if (ret < 0) {
        LOG(ERROR) << "IOCTL call failed with ret = " << ret;
    } else {
        LOG(INFO) << "HBM state set successfully. New state: " << state;
    }

    close(node);
}
} // namespace

class TeslaUdfpsHandler : public UdfpsHandler {
  public:
    TeslaUdfpsHandler() : hbmFodEnabled(false), mRbsHandle(nullptr), mExtraApi(nullptr) {
        mRbsHandle = dlopen("libRbsFlow.so", RTLD_NOW);
        if (mRbsHandle) {
            mExtraApi = reinterpret_cast<rbs_extra_api_t>(dlsym(mRbsHandle, "rbs_extra_api"));
            if (!mExtraApi) {
                LOG(ERROR) << "Failed to dlsym rbs_extra_api: " << dlerror();
            }
        } else {
            LOG(WARNING) << "Failed to dlopen libRbsFlow.so: " << dlerror();
        }
    }

    ~TeslaUdfpsHandler() override {
        disableHighBrightFod();
        if (mRbsHandle) {
            dlclose(mRbsHandle);
            mRbsHandle = nullptr;
            mExtraApi = nullptr;
        }
    }

    void onFingerDown(uint32_t x, uint32_t y, float minor, float major) override {
        (void)x;
        (void)y;
        (void)minor;
        (void)major;
        enableHighBrightFod();
    }

    void onFingerUp() override {
        disableHighBrightFod();
    }

    void onAuthenticationSucceeded() override {
        disableHighBrightFod();
    }

    void onAuthenticationFailed() override {
        disableHighBrightFod();
    }

    void cancel() override {
        onFingerUp();
    }

  private:
    typedef int (*rbs_extra_api_t)(uint32_t, const uint8_t*, uint32_t, uint8_t*, uint32_t*);

    void extraApiWrapper(uint32_t cidValue) {
        if (mExtraApi) {
            uint32_t in_data[2] = {cidValue, 3};
            uint8_t out_buf[32] = {0};
            uint32_t out_len = sizeof(out_buf);
            int rc = mExtraApi(7, reinterpret_cast<const uint8_t*>(in_data), sizeof(in_data), out_buf, &out_len);
            if (rc != 0) {
                LOG(ERROR) << "rbs_extra_api(7, " << cidValue << ") failed, error: " << rc;
            }
        }
    }

    void disableHighBrightFod() {
        std::lock_guard<std::mutex> lock(mSetHbmFodMutex);

        if (!hbmFodEnabled)
            return;

        extraApiWrapper(102);
        setHbmState(OFF);

        hbmFodEnabled = false;
    }

    void enableHighBrightFod() {
        std::lock_guard<std::mutex> lock(mSetHbmFodMutex);

        if (hbmFodEnabled)
            return;

        setHbmState(ON);
        extraApiWrapper(101);

        hbmFodEnabled = true;
    }

    bool hbmFodEnabled;
    std::mutex mSetHbmFodMutex;
    void* mRbsHandle;
    rbs_extra_api_t mExtraApi;
};

static UdfpsHandler* create_handler() {
    return new TeslaUdfpsHandler();
}

static void destroy_handler(UdfpsHandler* handler) {
    delete handler;
}

extern "C" UdfpsHandlerFactory UDFPS_HANDLER_FACTORY = {
    .create = create_handler,
    .destroy = destroy_handler,
};
