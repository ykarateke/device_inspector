package com.bearcode.device_inspector

import android.content.Context
import android.opengl.GLES10
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import javax.microedition.khronos.egl.EGL10
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.egl.EGLContext

class HardwareInfoProvider(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getHardwareInfo") {
            result.notImplemented()
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val info = mutableMapOf<String, Any?>()

                // CPU
                val cpu = mutableMapOf<String, Any?>()
                cpu["name"] = getCPUName()
                cpu["cores"] = Runtime.getRuntime().availableProcessors()
                cpu["architecture"] = Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"
                cpu["maxFrequencyMHz"] = getMaxCpuFrequencyMHz()
                cpu["hasNeuralEngine"] = hasNeuralNetworkAcceleration()

                // GPU — real renderer string via a throwaway EGL pbuffer context.
                val glInfo = queryGLInfo()
                val gpu = mutableMapOf<String, Any?>()
                gpu["name"] = glInfo?.first ?: "Unknown"
                gpu["supportsMetal"] = false
                gpu["supportsVulkan"] = hasVulkanSupport()
                gpu["openGLESVersion"] = glInfo?.second ?: getGLESVersion()

                // Display
                val display = mutableMapOf<String, Any?>()
                val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                val metrics = DisplayMetrics()
                @Suppress("DEPRECATION")
                wm.defaultDisplay.getRealMetrics(metrics)
                display["widthPixels"] = metrics.widthPixels
                display["heightPixels"] = metrics.heightPixels
                display["density"] = metrics.density.toDouble()
                @Suppress("DEPRECATION")
                display["refreshRate"] = wm.defaultDisplay.refreshRate.toInt()
                display["supportsHdr"] = isHdrCapable(wm)
                display["brightnessLevel"] = -1.0

                info["cpu"] = cpu
                info["gpu"] = gpu
                info["display"] = display
                info["tier"] = determineTier()

                result(info)
            } catch (e: Exception) {
                result.error("HARDWARE_INFO_ERROR", e.message, null)
            }
        }
    }

    private fun getCPUName(): String {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/bin/cat", "/proc/cpuinfo"))
            val reader = process.inputStream.bufferedReader()
            val text = reader.readText()
            reader.close()
            text.lines()
                .firstOrNull { it.startsWith("Hardware") }
                ?.substringAfter(":")
                ?.trim()
                ?: Build.HARDWARE
        } catch (e: Exception) {
            Build.HARDWARE
        }
    }

    /// Reads the SoC's advertised max clock speed from sysfs. Not available on all OEMs.
    private fun getMaxCpuFrequencyMHz(): Int {
        return try {
            val khz = java.io.File("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
                .readText()
                .trim()
                .toLong()
            (khz / 1000).toInt()
        } catch (e: Exception) {
            0
        }
    }

    /// NNAPI (on-device ML acceleration) landed in API 27. This is a capability proxy,
    /// not literal dedicated-NPU hardware detection — Android exposes no such API.
    private fun hasNeuralNetworkAcceleration(): Boolean = Build.VERSION.SDK_INT >= 27

    private fun hasVulkanSupport(): Boolean {
        return try {
            val pm = context.packageManager
            pm.hasSystemFeature(android.content.pm.PackageManager.FEATURE_VULKAN_HARDWARE_VERSION)
        } catch (e: Exception) {
            false
        }
    }

    private fun getGLESVersion(): String? {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val info = am.deviceConfigurationInfo
            "${info.reqGlEsVersion shr 16}.${info.reqGlEsVersion and 0xffff}"
        } catch (e: Exception) {
            null
        }
    }

    private fun isHdrCapable(wm: WindowManager): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                @Suppress("DEPRECATION")
                wm.defaultDisplay.isHdr
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun determineTier(): String {
        val cores = Runtime.getRuntime().availableProcessors()
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val memInfo = android.app.ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)
        val totalRam = memInfo.totalMem
        if (cores >= 8 && totalRam >= 8L * 1024 * 1024 * 1024) return "high"
        if (cores < 4 || totalRam < 4L * 1024 * 1024 * 1024) return "low"
        return "medium"
    }

    /// Creates an off-screen EGL context to read GL_RENDERER/GL_VERSION —
    /// the only way to get the real GPU name string on Android.
    private fun queryGLInfo(): Pair<String, String>? {
        var egl: EGL10? = null
        var display: javax.microedition.khronos.egl.EGLDisplay? = null
        var eglContext: EGLContext? = null
        var surface: javax.microedition.khronos.egl.EGLSurface? = null
        return try {
            egl = EGLContext.getEGL() as EGL10
            display = egl.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY)
            val version = IntArray(2)
            egl.eglInitialize(display, version)

            val configAttribs = intArrayOf(
                EGL10.EGL_RENDERABLE_TYPE, 4, // EGL_OPENGL_ES2_BIT
                EGL10.EGL_RED_SIZE, 8,
                EGL10.EGL_GREEN_SIZE, 8,
                EGL10.EGL_BLUE_SIZE, 8,
                EGL10.EGL_NONE
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val numConfigs = IntArray(1)
            egl.eglChooseConfig(display, configAttribs, configs, 1, numConfigs)
            if (numConfigs[0] == 0) return null
            val config = configs[0] ?: return null

            val contextAttribs = intArrayOf(0x3098, 2, EGL10.EGL_NONE) // EGL_CONTEXT_CLIENT_VERSION
            eglContext = egl.eglCreateContext(display, config, EGL10.EGL_NO_CONTEXT, contextAttribs)

            val pbufferAttribs = intArrayOf(EGL10.EGL_WIDTH, 1, EGL10.EGL_HEIGHT, 1, EGL10.EGL_NONE)
            surface = egl.eglCreatePbufferSurface(display, config, pbufferAttribs)

            egl.eglMakeCurrent(display, surface, surface, eglContext)

            val renderer = GLES10.glGetString(GLES10.GL_RENDERER)
            val glVersion = GLES10.glGetString(GLES10.GL_VERSION)
            if (renderer.isNullOrEmpty()) null else Pair(renderer, glVersion ?: "")
        } catch (e: Exception) {
            null
        } finally {
            try {
                if (egl != null && display != null) {
                    egl.eglMakeCurrent(display, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT)
                    if (surface != null) egl.eglDestroySurface(display, surface)
                    if (eglContext != null) egl.eglDestroyContext(display, eglContext)
                    egl.eglTerminate(display)
                }
            } catch (e: Exception) {
                // best-effort cleanup
            }
        }
    }
}
