package com.tfm.metas_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

private const val TAG = "MetasNative"

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "com.tfm.metas_app/auth_me").setMethodCallHandler { call, result ->
            if (call.method == "getAuthMe" || call.method == "fetch" || call.method == "post") {
                val url = call.argument<String>("url") ?: run {
                    result.error("INVALID_ARGS", "url required", null)
                    return@setMethodCallHandler
                }
                val token = call.argument<String>("token") ?: run {
                    result.error("INVALID_ARGS", "token required", null)
                    return@setMethodCallHandler
                }
                val requestBody = if (call.method == "post") {
                    call.argument<String>("body") ?: run {
                        result.error("INVALID_ARGS", "body required", null)
                        return@setMethodCallHandler
                    }
                } else {
                    null
                }
                thread {
                    try {
                        val conn = URL(url).openConnection() as HttpURLConnection
                        conn.requestMethod = if (call.method == "post") "POST" else "GET"
                        conn.connectTimeout = 15000
                        conn.readTimeout = 15000
                        conn.setRequestProperty("Authorization", "Bearer $token")
                        conn.setRequestProperty("Content-Type", "application/json")
                        conn.setRequestProperty("Accept", "application/json")
                        conn.setRequestProperty("Connection", "close")
                        if (requestBody != null) {
                            conn.doOutput = true
                            conn.outputStream.use { output ->
                                output.write(requestBody.toByteArray())
                                output.flush()
                            }
                        }
                        val code = conn.responseCode
                        val responseBody = if (code in 200..299) conn.inputStream.bufferedReader().readText()
                        else conn.errorStream?.bufferedReader()?.readText() ?: ""
                        conn.disconnect()
                        Log.d(TAG, "[${call.method}] <- status=$code | bodyLength=${responseBody.length} body=$responseBody")
                        runOnUiThread {
                            result.success(mapOf("statusCode" to code, "body" to responseBody))
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            result.error("NETWORK_ERROR", e.message, null)
                        }
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

