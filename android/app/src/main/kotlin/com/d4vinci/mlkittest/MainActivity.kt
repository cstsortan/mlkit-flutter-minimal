package com.d4vinci.mlkittest

import android.net.Uri
import android.os.Bundle
import com.google.firebase.ml.vision.FirebaseVision
import com.google.firebase.ml.vision.common.FirebaseVisionImage
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetector
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetectorOptions

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.R.attr.rotation
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata
import java.io.File


class MainActivity(): FlutterActivity() {
  private val CHANNEL: String = "vision_channel"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    val options = FirebaseVisionLabelDetectorOptions.Builder()
            .build()

    val detector = FirebaseVision.getInstance()
            .getVisionLabelDetector(options)

    MethodChannel(flutterView, CHANNEL)
            .setMethodCallHandler { call, result ->
              when (call.method) {
                "get_labels" -> {
                    val file = File(call.argument<String>("image_path"))
                    val image = FirebaseVisionImage.fromFilePath(baseContext, Uri.fromFile(file))
                  detector.detectInImage(image)
                          .addOnSuccessListener {firLabels ->
                            val labels: List<String> = firLabels.map { firLabel -> firLabel.label }
                            result.success(labels)
                          }
                          .addOnFailureListener {e ->
                            result.success(emptyArray<Any>())
                          }
                }
                else -> {
                  result.notImplemented()
                }
              }
            }


  }
}
