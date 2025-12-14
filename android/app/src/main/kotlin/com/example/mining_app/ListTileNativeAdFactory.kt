package com.supreet.idleminer

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

/**
 * NativeAdFactory for list tile style native ads
 * Factory ID: "listTile"
 */
class ListTileNativeAdFactory(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_list_tile, null) as NativeAdView

        // Set the media view
        adView.mediaView = adView.findViewById(R.id.ad_media)

        // Set other ad assets
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_icon)
        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)

        // Populate headline
        (adView.headlineView as? TextView)?.text = nativeAd.headline

        // Populate body
        nativeAd.body?.let { body ->
            (adView.bodyView as? TextView)?.text = body
            adView.bodyView?.visibility = View.VISIBLE
        } ?: run {
            adView.bodyView?.visibility = View.INVISIBLE
        }

        // Populate call to action
        nativeAd.callToAction?.let { cta ->
            (adView.callToActionView as? TextView)?.text = cta
            adView.callToActionView?.visibility = View.VISIBLE
        } ?: run {
            adView.callToActionView?.visibility = View.INVISIBLE
        }

        // Populate icon
        nativeAd.icon?.let { icon ->
            (adView.iconView as? ImageView)?.setImageDrawable(icon.drawable)
            adView.iconView?.visibility = View.VISIBLE
        } ?: run {
            adView.iconView?.visibility = View.GONE
        }

        // Populate advertiser
        nativeAd.advertiser?.let { advertiser ->
            (adView.advertiserView as? TextView)?.text = advertiser
            adView.advertiserView?.visibility = View.VISIBLE
        } ?: run {
            adView.advertiserView?.visibility = View.INVISIBLE
        }

        // Register the native ad view
        adView.setNativeAd(nativeAd)

        return adView
    }
}
