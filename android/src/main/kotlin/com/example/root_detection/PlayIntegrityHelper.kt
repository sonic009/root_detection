package com.example.root_detection

import android.content.Context
import com.google.android.play.core.integrity.*

class PlayIntegrityHelper(context: Context) {

    private val integrityManager = IntegrityManagerFactory.create(context)

    fun requestIntegrityToken(
        nonce: String,
        cloudProjectNumber: String,
        onSuccess: (String) -> Unit,
        onError: (Exception) -> Unit
    ) {
        val request = IntegrityTokenRequest.builder()
            .setNonce(nonce)
            .setCloudProjectNumber(cloudProjectNumber.toLong())
            .build()

        integrityManager.requestIntegrityToken(request)
            .addOnSuccessListener { response ->
                onSuccess(response.token())
            }
            .addOnFailureListener { exception ->
                onError(exception)
            }
    }
}
