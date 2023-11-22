import 'dart:io';

import 'package:flutter/foundation.dart';

// 전면 광고 ID
final INTERSTRITIAL_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/2220292088' // 실제 광고 ID
            : 'ca-app-pub-3940256099942544/1033173712' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/5729072507' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/4411468910' // 테스트 광고 ID
    );

// 보상형 전면 광고 ID
final REWARD_INTERSTRITIAL_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/3341802063' // 실제 광고 ID
            : 'ca-app-pub-3940256099942544/6978759866' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/8402557052' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/6978759866' // 테스트 광고 ID
    );

final BANNER_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/2851665717' // 실제 광고 ID
            : 'ca-app-pub-3940256099942544/6300978111' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/7668878128' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/2934735716' // 테스트 광고 ID
    );
